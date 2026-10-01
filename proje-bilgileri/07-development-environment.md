---
title: Geliştirme Ortamı
durum: Güncel
son-guncelleme: 2026-09-30
---

# Geliştirme Ortamı

← [İndeks](00-index.md)

Değerler **30 Eylül 2026'da makineden komutlarla okundu** (sürüm komutları, `podman images`, `flutter doctor`). Araç değişince bu doküman ve [teknoloji değişiklikleri](kayitlar/teknoloji-degisiklikleri.md) güncellenir.

## Makine

| Konu | Değer |
| --- | --- |
| İşletim sistemi | Fedora Linux 44 (Workstation Edition) |
| Çekirdek | 7.2.7-200.fc44.x86_64 |
| İşlemci | AMD Ryzen 7 250 (Radeon 780M) |
| Bellek | 22 GB |
| Kabuk | bash |

## Araç zinciri

| Araç | Sürüm | Not |
| --- | --- | --- |
| Git | 2.55.0 | |
| GitHub CLI (`gh`) | 2.97.0 | Repo durumu ve görünürlük kontrolü |
| Podman | 5.8.7 | Docker yerine; komutlar büyük ölçüde aynı |
| podman-compose | 1.6.0 | `podman compose up -d` |
| Dart | 3.13.0 (stable) | |
| Flutter | 3.47.0 (stable) | `flutter doctor`: Flutter, Android toolchain (SDK 36.0.0), Chrome, Linux toolchain ve ağ kaynakları tamam; sorun yok |
| JDK | 25 (sistem), 17 (Android araç zinciri için ayrı) | Android derlemesi JDK 17 kullanır |
| Node.js / npm | 24.16.0 / 11.13.0 | Projede kullanılmıyor; yardımcı araçlar için |
| Python | 3.14.7 (pip 26.2.1) | Projede kullanılmıyor; `podman-compose` için |
| Claude Code | 2.1.285 | Yapay zeka aracı, bkz. [Skill kataloğu](kayitlar/skill-katalogu.md) |

**Editörler:** VS Code 1.139.1 (Flatpak; `code` komutu PATH'te yok), Android Studio 2026.1.4.8 (Flatpak), Obsidian 1.13.7 (Flatpak).

**Kurulu olmayanlar:** `dotnet` (projede kullanılmayacak), `docker` (Podman kullanılıyor).

## Yerelde hazır konteyner imajları

| İmaj | Boyut | Projede |
| --- | --- | --- |
| `postgres:16` ve `postgres:16-alpine` | 458 MB, 297 MB | Uygulama veritabanı ve entegrasyon testi |
| `sonarqube:community` | 1.44 GB | Kod kalitesi taraması |
| `sonarsource/sonar-scanner-cli` | 1.01 GB | SonarQube tarayıcısı |

SonarQube imajı ve tarayıcı yerelde mevcut. **30 Eylül'de doğrulandı:** `sonarqube:community` 26.9.0.129388 yaklaşık 30 saniyede açıldı ve arayüz yanıt verdi. **Ancak Community sürümünde Dart dili yok** (0 Dart kuralı); ayrıntı ve karar: [SonarQube puanları](kayitlar/sonarqube-puanlari.md#doğrulama-kaydı-2026-09-30). Bu makinede daha önce başka bir SonarQube konteynerı çalıştırılmıştı (şu an durmuş, `9000` portunda); ona dokunulmadı.

## Portlar ve çakışma riski

| Servis | Planlanan port | Not |
| --- | --- | --- |
| PostgreSQL | 5432 | Makinede durmuş başka konteynerlar da 5432'yi kullanıyor; aynı anda ikisi çalışırsa çakışır. Proje compose dosyasında farklı bir host portu (ör. 5440) seçilecek |
| SonarQube | 9005 | Ders deposundaki compose ile aynı; makinedeki eski konteyner 9000 kullanıyor |
| Uygulama sunucusu | 8080 | Planlanan |

Not: [ADR-02](adr/02-kalite-araci-sonarqube-cloud.md) kararına göre (öneri) **yerel SonarQube sunucusu kurulmayacak**; Dart taraması SonarQube Cloud'da yapılacak. Aşağıdaki compose'ta SonarQube yer almayabilir.

## Servisler (planlanan compose)

```bash
podman compose up -d        # PostgreSQL ve SonarQube
cp .env.example .env        # değişkenleri doldur
```

Compose dosyası ve yapılandırma tablosu kod reposu açılınca eklenecek.

## Ortamı doğrulama

Aşağıdakiler ortamın sağlıklı olduğunu kanıtlar; değişiklikten sonra tekrar çalıştırılır:

```bash
flutter doctor              # tüm satırlar ✓ olmalı
dart --version
podman --version
podman images               # postgres:16 ve sonarqube:community görünmeli
```

## Bilinen eksikler

- Yerel SonarQube Community Dart'ı taramıyor; Dart taraması için SonarQube Cloud (ücretsiz plan) öneriliyor ([araştırma](kayitlar/sonarqube-puanlari.md#dart-desteği-araştırması-2026-09-30)). Yerelde kalite kanıtı `flutter analyze`, `dart analyze` ve kapsam raporu. Kalıcı yerel SonarQube (PostgreSQL destekli) compose'ta henüz tanımlanmadı.
- Paket sürümleri (pub.dev) henüz kontrol edilmedi; kod eklenince `pubspec.yaml` ile birlikte yazılır.
- `flutter doctor` yalnızca `eglinfo` (Linux masaüstü sürücü bilgisi) uyarısı verdi; masaüstü hedefini etkilemez, çözüm gerekirse `mesa-utils` paketi.
