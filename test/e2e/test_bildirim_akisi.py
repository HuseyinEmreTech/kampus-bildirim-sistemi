import pytest
import requests

from yardimci import (
    BASE_URL,
    SAHTE_PNG,
    bildirim_ac,
    giris_yap,
    yetki_basligi,
)

OGRENCI = "mehmet@ornek.edu"
GOREVLI_1 = "zeynep@ornek.edu"
GOREVLI_2 = "ali@ornek.edu"

# Sunucuda /api/reports henüz yok (main a6112fd). Endpoint gelince bu satırı
# ve aşağıdaki @ENDPOINT_YOK işaretlerini sil.
ENDPOINT_YOK = pytest.mark.xfail(
    reason="Sunucuda /api/reports henüz yok (main a6112fd)",
    strict=False,
)


@ENDPOINT_YOK
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


@ENDPOINT_YOK
def test_girissiz_istek_401_doner():
    yanit = requests.get(f"{BASE_URL}/api/reports", timeout=10)
    assert yanit.status_code == 401
    assert yanit.json()["error"]["code"] == "UNAUTHORIZED"


@ENDPOINT_YOK
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
