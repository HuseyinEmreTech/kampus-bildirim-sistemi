---
title: E2E Test ve Demo Rehberi
durum: Taslak
son-guncelleme: 2026-10-25
---

# E2E Test ve Demo Rehberi

Çalışan sunucuya HTTP isteği atan uçtan uca (E2E) testlerin kurulumu ve çalıştırılması. Sorumlu: Emir Kerem Çakıcı (#93). Bu doküman taslaktır; test dili ve CI kararı netleşince güncellenecek.

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
docker compose -f compose.prod.yaml up -d --build
python test/veri/seed_yukle.py
```

`.env` içindeki değerler doldurulur ve commit'e girmez. `http://localhost:8080/health` adresinde `OK` görülmelidir. Seed zaten yüklüyse betik "zaten yüklü" der.

Demo hesaplar (parola hepsinde `Demo.1234`): `ayse@ornek.edu`, `mehmet@ornek.edu` (Student); `zeynep@ornek.edu`, `ali@ornek.edu` (Staff).

## 4. Testleri çalıştırma

```
python -m pytest test/e2e -v
```

Test fotoğrafı 1x1 piksellik sahte PNG'dir; gerçek veri kullanılmaz.

## 5. Mevcut durum

| Test | Durum |
| --- | --- |
| Yanlış parola `401 INVALID_CREDENTIALS` | Geçiyor |
| Girişsiz liste isteği `401` | `xfail` |
| Öğrenci görevli listesini göremez `403` | `xfail` |
| Aç, üstlen, `409`, çöz, öğrenciye haber | `xfail` |

`xfail` sebebi: `main` (a6112fd) üzerinde `GET/POST /api/reports` `404 Route not found` dönüyor. Endpoint birleşince testler `XPASS` olur ve `test_bildirim_akisi.py` içindeki `@ENDPOINT_YOK` işaretleri silinir.

## 6. Henüz yapılmayanlar

- Web ve mobil E2E
- CI'a test işi eklenmesi (onay bekliyor)

## 7. Sık hatalar

| Belirti | Çözüm |
| --- | --- |
| `pytest` tanınmıyor | `python -m pytest` kullan |
| `collected 0 items` | Dosya `test_` ile başlamalı, `test/e2e` içinde ve kayıtlı olmalı |
| `wsl is not installed` | Yönetici PowerShell'de `wsl --install`, yeniden başlat |
| PowerShell'de `<` hatası | `seed_yukle.py` kullan |
| `IndentationError` | Dosyayı baştan yapıştır, girintiler 4 boşluk olmalı |