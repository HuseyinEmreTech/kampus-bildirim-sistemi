---
title: Geliştirme Ortamı
durum: Güncel
son-guncelleme: 2026-10-12
---

# Geliştirme Ortamı

← [İndeks](00-index.md)

Proje için **zorunlu tek bir makine veya araç yoktur.** Her geliştirici kendi işletim sistemini ve araçlarını kullanır; konteyner için **Podman veya Docker** serbesttir (komutlar büyük ölçüde aynıdır). Aşağıdaki **paylaşılan gereksinimler** herkes için geçerlidir; kişisel ortam ayrıntısını **her geliştirici kendi bölümüne kendisi yazar**. Yeni katılan, [Geliştirici ortamı şablonunu](#geliştirici-ortamı-şablonu) kopyalar.

## Paylaşılan gereksinimler

| Araç | Sürüm | Not |
| --- | --- | --- |
| Dart | 3.13.0 (stable) | |
| Flutter | 3.47.0 (stable) | |
| Git | 2.55.0 | |
| Konteyner | Podman + podman-compose **veya** Docker + Docker Compose | Hangisi kuruluysa; komutlar benzer |

## Geliştirici ortamları

| Geliştirici | İşletim sistemi | Konteyner | Ortam ayrıntısı |
| --- | --- | --- | --- |
| Hüseyin Emre (@HuseyinEmreTech) | Fedora Linux 44 | Podman | [aşağıda](#örnek-hüseyin-emre-huseyinemretech) |
| Ertuğrul Pekdemir (@ertrlpkdmr) | Windows 11 Pro | Docker | [aşağıda](#ertuğrul-pekdemir-ertrlpkdmr) |
| Çağdaş Kemal Ağca (@Cagdas3307) | (doldurulacak) | (doldurulacak) | |
| Yusuf Ekenel (@yusufekenel) | (doldurulacak) | (doldurulacak) | |
| Fatma Müberra Yener (@muberrayener) | (doldurulacak) | (doldurulacak) | |
| Emir Kerem Çakıcı (@KeremC23) | (doldurulacak) | (doldurulacak) | |

## Örnek: Hüseyin Emre (@HuseyinEmreTech)

Değerler **30 Eylül 2026'da makineden komutlarla okundu** (sürüm komutları, `podman images`, `flutter doctor`). Bu bölüm bir geliştiricinin **örneğidir**; herkes kendi bölümünü yazar. Araç değişince ilgili kişi kendi bölümünü ve [teknoloji değişiklikleri](kayitlar/teknoloji-degisiklikleri.md) günceller.

### Makine

| Konu | Değer |
| --- | --- |
| İşletim sistemi | Fedora Linux 44 (Workstation Edition) |
| Çekirdek | 7.2.7-200.fc44.x86_64 |
| İşlemci | AMD Ryzen 7 250 (Radeon 780M) |
| Bellek | 22 GB |
| Kabuk | bash |

### Araç zinciri

| Araç | Sürüm | Not |
| --- | --- | --- |
| Git | 2.55.0 | |
| GitHub CLI (`gh`) | 2.97.0 | Repo durumu ve görünürlük kontrolü |
| Podman | 5.8.7 | Bu ortamda Docker yerine; komutlar büyük ölçüde aynı. Docker kullanmak serbesttir |
| podman-compose | 1.6.0 | `podman compose up -d` |
| Dart | 3.13.0 (stable) | |
| Flutter | 3.47.0 (stable) | `flutter doctor`: Flutter, Android toolchain (SDK 36.0.0), Chrome, Linux toolchain ve ağ kaynakları tamam; sorun yok |
| JDK | 25 (sistem), 17 (Android araç zinciri için ayrı) | Android derlemesi JDK 17 kullanır |
| Node.js / npm | 24.16.0 / 11.13.0 | Projede kullanılmıyor; yardımcı araçlar için |
| Python | 3.14.7 (pip 26.2.1) | Projede kullanılmıyor; `podman-compose` için |
| Claude Code | 2.1.285 | Yapay zeka aracı, bkz. [Skill kataloğu](kayitlar/skill-katalogu.md) |

**Editörler:** VS Code 1.139.1 (Flatpak; `code` komutu PATH'te yok), Android Studio 2026.1.4.8 (Flatpak), Obsidian 1.13.7 (Flatpak).

**Kurulu olmayanlar (bu ortamda):** `dotnet` (projede kullanılmayacak), `docker` (bu ortamda Podman kullanılıyor; diğer geliştiriciler Docker kullanabilir).

### Yerelde hazır konteyner imajları

| İmaj | Boyut | Projede |
| --- | --- | --- |
| `postgres:16` ve `postgres:16-alpine` | 458 MB, 297 MB | Uygulama veritabanı ve entegrasyon testi |
| `sonarqube:community` | 1.44 GB | Kod kalitesi taraması (yerel; Dart taramaz) |
| `sonarsource/sonar-scanner-cli` | 1.01 GB | SonarQube tarayıcısı |

SonarQube imajı ve tarayıcı yerelde mevcut. **30 Eylül'de doğrulandı:** `sonarqube:community` 26.9.0.129388 yaklaşık 30 saniyede açıldı ve arayüz yanıt verdi. **Ancak Community sürümünde Dart dili yok** (0 Dart kuralı); ayrıntı ve karar: [SonarQube puanları](kayitlar/sonarqube-puanlari.md#doğrulama-kaydı-2026-09-30). Dart taraması artık SonarQube Cloud'da yapılıyor ([ADR-02](adr/02-kalite-araci-sonarqube-cloud.md)). Bu makinede daha önce başka bir SonarQube konteynerı çalıştırılmıştı (şu an durmuş, `9000` portunda); ona dokunulmadı.

### Portlar ve çakışma riski

| Servis | Planlanan port | Not |
| --- | --- | --- |
| PostgreSQL | 5432 | Makinede durmuş başka konteynerlar da 5432'yi kullanıyor; aynı anda ikisi çalışırsa çakışır. Proje compose dosyasında farklı bir host portu (ör. 5440) seçilecek |
| SonarQube | 9005 | Yerel; ders deposundaki compose ile aynı. Dart taraması Cloud'da yapıldığı için isteğe bağlı |
| Uygulama sunucusu | 8080 | Planlanan |

Not: [ADR-02](adr/02-kalite-araci-sonarqube-cloud.md) kararına göre **yerel SonarQube sunucusu kurulmayacak**; Dart taraması SonarQube Cloud'da yapılıyor.

## Ertuğrul Pekdemir (@ertrlpkdmr)

Değerler **12 Ekim 2026'da makineden komutlarla okundu** (`flutter --version`, `dart --version`, `docker --version`, PowerShell `Get-CimInstance`).

- İşletim sistemi: Microsoft Windows 11 Pro
- Konteyner: Docker 29.6.2
- Dart / Flutter sürümü: Dart 3.13.5, Flutter 3.47.7 (stable). Paylaşılan gereksinimden (3.13.0 / 3.47.0) yalnızca yama sürümü farklı.
- Editör: VS Code (Dart eklentisiyle; altyapı ve SQL işleri için), Android Studio da kurulu (Android SDK ve emülatör için)
- Bilinen farklar / notlar: Kabuk PowerShell; README komutlarında `podman` yerine `docker` yazılır. PowerShell `<` yönlendirmesini desteklemediği için `psql ... < dosya.sql` komutları `cmd /c "..."` içinde çalıştırılır (12 Ekim 2026'da bu makinede kurulum, migration ve seed bu yolla doğrulandı). Flutter 3.41.2 (Dart 3.11.0) projenin `sdk: ^3.13.0` şartını karşılamadığı için `flutter upgrade --force` ile güncellendi; `--force`, Windows git'in Flutter klasöründeki `.sh` dosyalarının satır sonlarını değiştirmesi yüzünden gerekti.

## Geliştirici ortamı şablonu

Yeni katılan, aşağıdaki bloğu kopyalayıp kendine göre doldurur; sonucu **yukarıdaki "Geliştirici ortamları" tablosuna** ekler (ve isterse kişisel planına yazar).

```markdown
### <Ad Soyad> (@github)

- İşletim sistemi:
- Konteyner: Podman / Docker (+ sürüm)
- Dart / Flutter sürümü:
- Editör:
- Bilinen farklar / notlar:
```

## Servisler (compose)

```bash
cp .env.example .env        # önce bu: değişkenleri doldur, şifreyi değiştir
podman compose up -d        # Docker kullanan: docker compose up -d
```

- Sıra önemli: `compose.yaml` şifreyi yalnızca `.env`'den alır; `.env` yoksa `up` "şifre eksik" hatasıyla durur.
- PostgreSQL 16 `localhost:5440` adresinde açılır (5432 başka konteynerlarla çakışmasın diye). `db/migrations/` içindeki dosyalar ilk açılışta sırayla çalışır.
- Örnek veri ve sonradan eklenen migration'ı elle uygulama komutları: [README §10](../README.md#10-kurulum-ve-çalıştırma).
- Docker kullanan, komutlarda `podman` yerine `docker` yazar.

## Ortamı doğrulama

Aşağıdakiler ortamın sağlıklı olduğunu kanıtlar; değişiklikten sonra tekrar çalıştırılır:

```bash
flutter doctor              # tüm satırlar ✓ olmalı
dart --version
podman --version            # Docker kullanan: docker --version
podman images               # Docker kullanan: docker images
```

## Bilinen eksikler

- Yerel SonarQube Community Dart'ı taramıyor; Dart taraması SonarQube Cloud'da yapılıyor ([ADR-02](adr/02-kalite-araci-sonarqube-cloud.md)). Yerelde kalite kanıtı `flutter analyze`, `dart analyze` ve kapsam raporu.
- Paket sürümleri (pub.dev) henüz kontrol edilmedi; kod eklenince `pubspec.yaml` ile birlikte yazılır.
- `flutter doctor` yalnızca `eglinfo` (Linux masaüstü sürücü bilgisi) uyarısı verdi; masaüstü hedefini etkilemez, çözüm gerekirse `mesa-utils` paketi.
