from functools import cache

import requests

from yardimci import (
    BASE_URL,
    SAHTE_PNG,
    bildirim_ac,
    bildirim_istegi,
    giris_yap as _giris_yap,
    yetki_basligi,
)

OGRENCI = "mehmet@ornek.edu"
GOREVLI_1 = "zeynep@ornek.edu"
GOREVLI_2 = "ali@ornek.edu"
IKINCI_OGRENCI = "ayse@ornek.edu"
BES_MB = 5 * 1024 * 1024

# Sunucu dakikada en fazla beş giriş isteği kabul eder.
giris_yap = cache(_giris_yap)

def test_bildirim_acilir_ustlenilir_cozulur_ogrenciye_haber_gider():
    ogrenci = giris_yap(OGRENCI)
    gorevli_1 = giris_yap(GOREVLI_1)
    gorevli_2 = giris_yap(GOREVLI_2)

    # 1. Öğrenci bildirim açar
    bildirim = bildirim_ac(ogrenci, "E2E testi: koridor lambası yanmıyor")
    rapor_id = bildirim["reportId"]
    assert bildirim["status"] == "Yeni"

    # 2. Birinci görevli üstlenir
    yanit = requests.put(
        f"{BASE_URL}/api/reports/{rapor_id}/assignment",
        headers=yetki_basligi(gorevli_1),
        timeout=10,
    )
    assert yanit.status_code == 200, yanit.text
    assert yanit.json()["status"] == "Ustlenildi"

    # 3. İkinci görevli de üstlenmeye çalışır: 409 almalı
    yanit = requests.put(
        f"{BASE_URL}/api/reports/{rapor_id}/assignment",
        headers=yetki_basligi(gorevli_2),
        timeout=10,
    )
    assert yanit.status_code == 409
    assert yanit.json()["error"]["code"] == "CONFLICT"

    # 4. Üstlenmeyen görevli çözemez
    yanit = requests.put(
        f"{BASE_URL}/api/reports/{rapor_id}/resolution",
        headers=yetki_basligi(gorevli_2),
        data={"note": "Ben çözdüm"},
        files={"resolutionPhoto": ("sonuc.png", SAHTE_PNG, "image/png")},
        timeout=15,
    )
    assert yanit.status_code == 403

    # 5. Üstlenen görevli çözer
    yanit = requests.put(
        f"{BASE_URL}/api/reports/{rapor_id}/resolution",
        headers=yetki_basligi(gorevli_1),
        data={"note": "Lamba değiştirildi."},
        files={"resolutionPhoto": ("sonuc.png", SAHTE_PNG, "image/png")},
        timeout=15,
    )
    assert yanit.status_code == 200, yanit.text
    assert yanit.json()["status"] == "Cozuldu"

    # 6. Öğrenci bildirimlerinde "çözüldü" haberini görür
    yanit = requests.get(
        f"{BASE_URL}/api/me/notifications",
        headers=yetki_basligi(ogrenci),
        timeout=10,
    )
    assert yanit.status_code == 200
    haberler = yanit.json()
    assert haberler["unreadCount"] >= 1
    assert any(
        h["reportId"] == rapor_id and h["type"] == "ReportResolved"
        for h in haberler["items"]
    )


def test_girissiz_istek_401_doner():
    yanit = requests.get(f"{BASE_URL}/api/reports", timeout=10)
    assert yanit.status_code == 401
    assert yanit.json()["error"]["code"] == "UNAUTHORIZED"


def test_ogrenci_gorevli_listesini_goremez():
    ogrenci = giris_yap(OGRENCI)
    yanit = requests.get(
        f"{BASE_URL}/api/reports",
        headers=yetki_basligi(ogrenci),
        timeout=10,
    )
    assert yanit.status_code == 403
    assert yanit.json()["error"]["code"] == "FORBIDDEN"


def test_yanlis_parola_401_doner():
    yanit = requests.post(
        f"{BASE_URL}/api/auth/login",
        json={"email": "ayse@ornek.edu", "password": "yanlis-parola"},
        timeout=10,
    )
    assert yanit.status_code == 401
    assert yanit.json()["error"]["code"] == "INVALID_CREDENTIALS"


def _ustlenilmis_bildirim():
    ogrenci = giris_yap(OGRENCI)
    gorevli = giris_yap(GOREVLI_1)
    rapor_id = bildirim_ac(ogrenci, "E2E testi: arızalı kapı")["reportId"]
    yanit = requests.put(
        f"{BASE_URL}/api/reports/{rapor_id}/assignment",
        headers=yetki_basligi(gorevli),
        timeout=10,
    )
    assert yanit.status_code == 200, yanit.text
    return rapor_id, gorevli


def test_baska_ogrencinin_bildirimi_404():
    sahip = giris_yap(OGRENCI)
    diger_ogrenci = giris_yap(IKINCI_OGRENCI)
    rapor_id = bildirim_ac(sahip, "E2E testi: öğrenci bildirim detayı")["reportId"]
    adres = f"{BASE_URL}/api/reports/{rapor_id}"

    sahip_yaniti = requests.get(adres, headers=yetki_basligi(sahip), timeout=10)
    assert sahip_yaniti.status_code == 200, sahip_yaniti.text

    yanit = requests.get(adres, headers=yetki_basligi(diger_ogrenci), timeout=10)
    assert yanit.status_code == 404, yanit.text
    assert yanit.json()["error"]["code"] == "NOT_FOUND"


def test_cift_cozme_409():
    rapor_id, gorevli = _ustlenilmis_bildirim()
    adres = f"{BASE_URL}/api/reports/{rapor_id}/resolution"
    basliklar = yetki_basligi(gorevli)
    dosyalar = {"resolutionPhoto": ("sonuc.png", SAHTE_PNG, "image/png")}

    ilk = requests.put(adres, headers=basliklar, files=dosyalar, timeout=15)
    assert ilk.status_code == 200, ilk.text

    ikinci = requests.put(adres, headers=basliklar, files=dosyalar, timeout=15)
    assert ikinci.status_code == 409, ikinci.text
    assert ikinci.json()["error"]["code"] == "INVALID_TRANSITION"


def test_sonuc_fotografsiz_cozulemez():
    rapor_id, gorevli = _ustlenilmis_bildirim()
    yanit = requests.put(
        f"{BASE_URL}/api/reports/{rapor_id}/resolution",
        headers=yetki_basligi(gorevli),
        files={"note": (None, "Fotoğraf eklenmedi.")},
        timeout=15,
    )
    assert yanit.status_code == 400, yanit.text
    hata = yanit.json()["error"]
    assert hata["code"] == "VALIDATION_ERROR"
    assert hata["details"] == "resolutionPhoto"


def test_bes_mb_ustu_foto_reddedilir():
    ogrenci = giris_yap(OGRENCI)
    foto = SAHTE_PNG.ljust(BES_MB + 1, b"\0")

    yanit = bildirim_istegi(ogrenci, "E2E testi: boyut sınırı", foto)
    assert yanit.status_code == 400, yanit.text
    hata = yanit.json()["error"]
    assert hata["code"] == "VALIDATION_ERROR"
    assert hata["details"] == "photo"
    assert "5 MB" in hata["message"]
