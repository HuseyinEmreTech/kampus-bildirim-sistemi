---
title: Başlangıç Rehberi
durum: Güncel
son-guncelleme: 2026-10-02
---

# Başlangıç Rehberi

← [İndeks](../00-index.md) · [Ekip ve yol haritası](../10-ekip-ve-yol-haritasi.md)

Ekibe yeni katıldıysan buradan başla. Sırayla oku ve uygula; her adımın sonunda ne görmen gerektiği yazıyor.

## 1. Önce bunları oku (30 dakika)

1. [Proje kapsamı](../01-project-scope.md): ne yapıyoruz, neden.
2. [Kullanıcı hikayeleri](../04-user-stories.md): uygulama kime ne yapıyor.
3. [Domain tasarımı](../03-domain-design.md): bildirimin durumları ve kurallar (Rule 00-07).
4. [Kod mimarisi ve korumalar](../11-kod-mimarisi-ve-korumalar.md): kod nereye yazılır, nereye yazılmaz.
5. [Ekip ve yol haritası](../10-ekip-ve-yol-haritasi.md): kim ne yapıyor, nasıl çalışıyoruz.
6. Kendi plan dosyan: [Hüseyin Emre](huseyin-emre.md), [Ertuğrul Pekdemir](ertugrul-pekdemir.md), [Murat Yaman](murat-yaman.md), [Yusuf Ekenel](yusuf-ekenel.md).

## 2. Kurulum

Sürümler projede kullanılanla aynı olmalı; daha eskiyse güncelle.

| Araç | En az | Nereden | Kontrol komutu |
| --- | --- | --- | --- |
| Git | 2.40 | [git-scm.com](https://git-scm.com/downloads) | `git --version` |
| Flutter (Dart'ı içerir) | 3.47.0 (Dart 3.13.0) | [docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install) | `flutter --version` |
| Android Studio (Android SDK ve emülatör) | güncel | [developer.android.com/studio](https://developer.android.com/studio) | `flutter doctor` |
| VS Code ve Flutter eklentisi | güncel | [code.visualstudio.com](https://code.visualstudio.com) | |
| Docker Desktop **veya** Podman (yalnızca veritabanı işleri için) | güncel | [docker.com](https://www.docker.com/products/docker-desktop/) / [podman.io](https://podman.io) | `docker --version` veya `podman --version` |
| GitHub CLI (isteğe bağlı) | güncel | [cli.github.com](https://cli.github.com) | `gh --version` |

Bitince çalıştır:

```bash
flutter doctor
```

Beklenen: Flutter, Android toolchain ve Android Studio satırları `[✓]`. `[!]` olan satır varsa çıktıyı kurulum issue'na yapıştır.

Git'e kendini tanıt (GitHub'daki e-postanla aynı olsun, yoksa commit'lerin profiline bağlanmaz):

```bash
git config --global user.name "Ad Soyad"
git config --global user.email "github-e-postan@ornek.com"
```

## 3. Repo'yu al

GitHub'dan gelen daveti kabul et (e-posta veya github.com/notifications). Sonra:

```bash
git clone https://github.com/HuseyinEmreTech/kampus-bildirim-sistemi.git
cd kampus-bildirim-sistemi
```

Kod iskeleti eklendikten sonra (hafta 4) bağımlılıkları kur ve testleri çalıştır:

```bash
flutter pub get
dart test test/architecture_test.dart
```

Beklenen: `All tests passed!`

## 4. Bir görevin baştan sona yolu

Örnek: sana 12 numaralı issue atandı.

```bash
# 1. main'i güncelle
git switch main
git pull

# 2. Görev için branch aç (issue numarası + kısa ad)
git switch -c feature/12-giris-ekrani

# 3. Çalış, küçük adımlarla commit at (mesaj Türkçe ve önekli)
git add packages/app/lib/screens/login_screen.dart
git commit -m "feat: giriş ekranı iskeleti"

# 4. Göndermeden önce kontrol et
dart format .
dart analyze --fatal-infos
dart test            # ya da kendi paketinde: flutter test

# 5. Gönder
git push -u origin feature/12-giris-ekrani
```

Sonra GitHub'da **Compare & pull request**: şablonu doldur, açıklamaya `Closes #12` yaz, inceleyici olarak Hüseyin Emre'yi ekle.

İnceleme yorum gelirse aynı branch'te düzelt, commit at, `git push`. PR birleşince branch otomatik silinir; sen de yerelde `git switch main && git pull` yap.

**Asla:** `main` üzerinde çalışma, `git push --force` kullanma, başkasının branch'ine sormadan commit atma. `main` korumalı olduğu için bunlar zaten reddedilir.

Commit önekleri: `feat:` (özellik), `fix:` (hata), `test:` (test), `docs:` (doküman), `refactor:` (davranışı değiştirmeyen düzenleme), `chore:` (ayar, bağımlılık).

## 5. Yapay zeka ile nasıl çalışıyoruz

Bu ders yapay zeka destekli geliştirme dersi; yapay zeka kullanmak beklenen bir şey. Ama hoca kodları soracak: **anlatamadığın satır senin değildir.**

Adımlar:

1. **Bağlam ver.** Aracına önce [AGENTS.md](../../AGENTS.md) dosyasını okut (Claude Code bunu kendisi okur), sonra issue metnini yapıştır.
2. **Küçük iste.** "Tüm ekranı yaz" değil, "giriş ekranına e-posta alanı ekle, doğrulamasıyla" gibi.
3. **Önce plan iste, sonra kod.** "Kod yazmadan önce ne yapacağını ve hangi dosyalara dokunacağını söyle." Dokunulmayacak dosyalar listesindeki bir dosya geçiyorsa durdur.
4. **Özeti ve varsayımları oku.** Anlamadığın her satırı sor: "Bu satır ne yapıyor, neden gerekli?"
5. **Testleri sen çalıştır.** Araç "testler geçiyor" dese de kendin çalıştır.
6. **PR şablonundaki yapay zeka bölümünü doldur:** hangi araç, ne sordun, çıktıda neyi değiştirdin, neyi anlamadın.

Yasaklar:

- Testi geçsin diye testi değiştirmek ya da silmek.
- Yeni paket eklemek (gerekiyorsa issue'da sor; paketin güncel ve güvenilir olduğu kontrol edilir).
- Gizli bilgi, şifre, gerçek öğrenci verisi ve başkasının kişisel bilgisini prompt'a yapıştırmak.
- Araç "bunu da düzelttim" diyerek görev dışı dosyalara dokunduysa o değişikliği almak.

## 6. Takıldığında

- 30 dakikadan fazla takıldıysan issue'ya yorum yaz: ne yapmaya çalıştın, ne denedin, hata mesajı (tam metin).
- Hata mesajını yapay zekaya da, ekibe de **olduğu gibi** yapıştır; özetleme.
- Kurulum sorunları için `flutter doctor -v` çıktısını ekle.

## 7. Her pazar

Kendi plan dosyanın sonundaki **Günlük** bölümüne o haftayı yaz: ne yaptın (PR numaralarıyla), neyi öğrendin, yapay zekayı nerede kullandın, nerede takıldın. Dönem sonunda katkı raporun buradan çıkacak.
