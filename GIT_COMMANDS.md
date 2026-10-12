# Git Komutları - README'ye Eklenebilecek Bölüm

## Repo Klonlama ve İlk Kurulum

```bash
# Repo klonla
gh repo clone HuseyinEmreTech/kampus-bildirim-sistemi
cd kampus-bildirim-sistemi

# Bağımlılıkları yükle (Dart workspace)
dart pub get

# PostgreSQL başlat (podman-compose)
podman compose up -d

# Environment dosyası
cp .env.example .env
# .env dosyasını düzenle: DATABASE_URL, JWT_SECRET, CAMPUS_BOUNDS, PHOTO_DIR
```

## Geliştirme Döngüsü (Her Sprint İçin)

```bash
# 1. Main'i güncelle
git checkout main
git pull origin main

# 2. Yeni issue için branch aç (örnek)
git checkout -b feature/hafta05-application-usecases
# veya test/hafta05-kabul-rule02-04-05

# 3. Kod yaz, test et
dart format .
dart analyze --fatal-infos
dart test

# 4. Commit (Türkçe, önekli)
git add .
git commit -m "feat: application usecase'leri create, assign, resolve, list eklendi"

# 5. Push ve PR aç
git push origin feature/hafta05-application-usecases
gh pr create --title "feat: Application UseCase'ler" --body-file .github/pull_request_template.md --base main

# 6. CI yeşil, 1 onay aldıktan sonra squash merge (GitHub web'ten)
# 7. Branch sil
git checkout main
git pull origin main
git branch -d feature/hafta05-application-usecases
```

## Sprint Başlangıcı (Pazartesi)

```bash
# Milestone ve issue'ları gör
gh issue list --milestone "Hafta 05 (12-18 Eki)" --state open

# Kendi issue'ını al
gh issue view 15  # örn: #15 Application UseCase'ler

# Branch aç
git checkout -b feature/hafta05-<kisa-ad>
```

## Günlük Standup (Async - Issue Yorumunda)

```bash
# Issue'a günlük rapor yorumu ekle
gh issue comment 15 --body "
**Gün:** 13 Ekim 2026
**Yaptım:** UseCase interface'ler push edildi, Test yazıldı
**Yapamadım:** RepositoryImpl henüz başlayamadım
**Blok:** Yok
**Yarın:** RepositoryImpl başla, FileStorage araştır
**AI Kullanımı:** UseCase template için Claude kullandım, manuel doğruladım
"
```

## PR Kontrol Listesi (Merge Öncesi)

```bash
# Local'de tam kontrol
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test test/architecture_test.dart

# Paket testleri
for d in packages/domain packages/application packages/contracts packages/infrastructure packages/server; do
  if find "$d/test" -name '*_test.dart' 2>/dev/null | grep -q .; then
    (cd "$d" && dart test -x bekliyor -x db)
  fi
done

# Flutter testler
cd packages/app && flutter test && cd ../..

# Hepsi yeşil → PR aç
gh pr create --fill --base main
```

## Collaborator Ekleme (Repo Sahibi İçin)

```bash
gh api repos/HuseyinEmreTech/kampus-bildirim-sistemi/collaborators/<USERNAME> -X PUT -f permission=push
# <USERNAME>: ertrlpkdmr, Cagdas3307, muberrayener, yusufekenel, KeremC23
```

## Label Yönetimi

```bash
# Tüm label'ları listele
gh api repos/HuseyinEmreTech/kampus-bildirim-sistemi/labels --jq '.[].name'

# Eksik label ekle
gh api repos/HuseyinEmreTech/kampus-bildirim-sistemi/labels -f name="app:mobile" -f color="0075ca" -f description="Flutter mobile (Android/iOS)"
```

## Release (Hafta 12 ve 15)

```bash
# Version bump
# pubspec.yaml version: 1.0.0+1 -> 1.0.1+2

# Tag ve release
git tag -a v1.0.0 -m "Release v1.0.0 - Hafta 12 Demo"
git push origin v1.0.0

# GitHub Release (APK artifact ile)
gh release create v1.0.0 --title "v1.0.0 - Hafta 12 Demo" --notes-file CHANGELOG.md packages/app/build/app-release.apk
```

## Yararlı Alias'lar (~/.bashrc veya ~/.zshrc'ye ekle)

```bash
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push origin HEAD'
alias gpl='git pull origin main'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gd='git diff'
alias gl='git log --oneline -10'
alias dtest='dart test'
alias dan='dart analyze --fatal-infos'
alias dfor='dart format .'
alias ft='flutter test'
alias fbr='flutter build apk --release'
```