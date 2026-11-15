---
title: E2E Test ve Demo Rehberi
durum: Güncel
son-guncelleme: 2026-11-15
---

# E2E Test ve Demo Rehberi

← [İndeks](../00-index.md)

Çalışan sunucuya HTTP isteği atan uçtan uca (E2E) testlerin kurulumu ve çalıştırılması. Sorumlu: Emir Kerem Çakıcı (#93).

## 1. Gereksinimler

| Araç | Not |
| --- | --- |
| Python 3.11+ | Kurulumda "Add python.exe to PATH" işaretlenir |
| Docker Desktop | Windows'ta önce `wsl --install` ve yeniden başlatma gerekir |
| Git | `git --version` ile kontrol edilir |

## 2. Kurulum

```
python -m venv .venv
.venv\Scripts\activate
python -m pip install pytest requests
```

`pytest` komutu tanınmazsa her yerde `python -m pytest` kullanılır.

## 3. Sunucu ve demo verisi

```
copy .env.example .env
# .env içindeki yerel DB parolalarını ve iki farklı JWT sırrını ayarla.
docker compose -f compose.prod.yaml up -d --build
python test/veri/seed_yukle.py
```

`.env` içindeki değerler doldurulur ve commit'e girmez. `http://localhost:8080/health` adresinde `OK` görülmelidir. Seed zaten yüklüyse betik "zaten yüklü" der.

Demo hesaplar (parola hepsinde `Demo.1234`): `ayse@ornek.edu`, `mehmet@ornek.edu` (Student); `zeynep@ornek.edu`, `ali@ornek.edu` (Staff).

## 4. Testleri çalıştırma

```
python -m pytest test/e2e -v
```

Varsayılan adres `http://localhost:8080`. Farklı port için `E2E_BASE_URL` değerini ayarla. Temiz, izole bir test sunucusu kullan. Giriş sınırı nedeniyle tekrar çalıştırmadan önce bir dakika bekle veya test sunucusunu yeniden başlat. Testler test veritabanına yeni bildirimler yazar.

Test fotoğrafı 1x1 piksellik sahte PNG'dir; gerçek veri kullanılmaz.

## 5. Beklenen sonuç

Sekiz test çalışır. Sunucu kapalıysa yerel çalıştırma atlanır. Kabul doğrulamasında atlanan test olmamalı.

- Yanlış parola ve girişsiz istek reddedilir. Öğrenci görevli listesini göremez.
- Bildirim açılır, tek görevli üstlenir. Yalnızca üstlenen görevli sonuç fotoğrafıyla çözer ve öğrenciye haber gider.
- Bildirim detayı sahibine açılır, diğer öğrenciye `404 NOT_FOUND` döner. Bu senaryo [#159](https://github.com/HuseyinEmreTech/kampus-bildirim-sistemi/issues/159) ile gelen detay ucunu gerektirir.
- İkinci çözme isteği `409` döner. Sonuç fotoğrafı olmayan çözüm ve 5 MB üstündeki bildirim fotoğrafı reddedilir.

## 6. Sık hatalar

| Belirti | Çözüm |
| --- | --- |
| `pytest` tanınmıyor | `python -m pytest` kullan |
| `collected 0 items` | Dosya `test_` ile başlamalı, `test/e2e` içinde ve kayıtlı olmalı |
| `wsl is not installed` | Yönetici PowerShell'de `wsl --install`, yeniden başlat |
| PowerShell'de `<` hatası | `seed_yukle.py` kullan |
| `IndentationError` | Dosyayı baştan yapıştır, girintiler 4 boşluk olmalı |
