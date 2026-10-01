---
title: Hata Kayıtları
durum: Güncel
son-guncelleme: 2026-09-30
---

# Hata Kayıtları

← [İndeks](../00-index.md)

Yapılan her hata burada kayıtlıdır: ne oldu, neden oldu, nasıl fark edildi, nasıl düzeltildi, tekrarını önlemek için ne yapıldı. Amaç suçlamak değil, öğrenmek ve zorluklar ve çözümler bölümünü gerçek verilerle beslemek.

## Yapay zeka hataları

Yapay zekanın yanıldığı yerler. Çıktının okunup doğrulandığının kanıtıdır.

| Tarih | Nerede | Ne oldu | Kök neden | Nasıl fark edildi | Düzeltme | Önlem |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-09-25 | Ders deposunu inceleme | README'de olmayan bir GitHub bağlantısı uydurdu | Kaynakta olmayan bilgiyi tamamlama | Bağlantı kaynak dosyada aranınca bulunamadı | Yalnızca depodaki dosyalar kaynak alındı | Her iddiaya kaynak dosya yazmak |
| 2026-09-30 | Katman diyagramı | Bağımlılık yönü ters yazılmıştı (`Domain` → `Infrastructure`) | Katman sırasının bağımlılık yönü sanılması | Ders materyalindeki Clean Architecture tanımıyla karşılaştırınca | `Domain` hiçbir katmana bağlı olmayacak biçimde düzeltildi ([mimari](../02-architecture-overview.md#katmanlar)) | Mimari diyagramları Mermaid ile okunabilir çizmek ve yönü açık yazmak |
| 2026-09-30 | Veritabanı gerekçesi | "Firebase yasak" gibi okunabilecek bir yorum yazmıştı | Çıkarımın kural gibi sunulması | Ders şartı yeniden okununca (SQL, NoSQL, bellek içi serbest) | Yorumun bir çıkarım olduğu belirtildi ([ADR-01](../adr/01-dart-backend-postgresql.md)) | "Ders söyledi" ile "çıkarım" ayrımını yazmak |
| 2026-09-30 | Doküman bağlantıları | `adr/` ve `journal/` klasör bağlantıları çözülemiyordu; iki dosya hiçbir yerden bağlanmamıştı | Klasöre bağlantı verilmesi, günlük dosyasının indekse eklenmemesi | Obsidian CLI taraması (çözülemeyen bağlantılar ve yetim dosyalar) | Bağlantılar dosyalara yönlendirildi; günlük haftalık kayıtlara birleştirildi | Doküman eklerken Obsidian CLI taramasını çalıştırmak |

## Süreç hataları

Bizim yaptığımız hatalar.

| Tarih | Nerede | Ne oldu | Kök neden | Nasıl fark edildi | Düzeltme | Önlem |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-09-30 | `.gitignore` | Ders deposu klasörü adı yanlış yazıldığı (`devolopment`) için ignore edilmiyordu | Yazım hatası | `git status` klasörü gösterince | Ad düzeltildi | Ignore kuralını `git check-ignore` ile test etmek |
| 2026-09-30 | Repo görünürlüğü | Kişisel ders notlarının herkese açık repo'da olma riski geç fark edildi | Repo görünürlüğünün kontrol edilmemesi | `gh repo view` ile görünürlük kontrol edilince | Kişisel notlar ayrı ve ignore edilen bir klasöre taşındı; hiçbiri push edilmemişti | Push öncesi kontrol listesi |
| 2026-09-30 | Ortam dokümanı | 25 Eylül notlarından doğrulanmadan aktarıldı: "SonarQube imajı henüz çekilmedi" yazıyordu, oysa imaj yerelde vardı; VS Code ve Claude Code sürümleri de eskiydi | Eski notun güncel doğrulama olmadan kopyalanması | Ortamı sorunca komutlarla yeniden okuyunca (`podman images`, sürüm komutları) | Doküman komut çıktılarıyla yeniden yazıldı; port çakışma riski de eklendi ([ortam](../07-development-environment.md)) | Ortam bilgisini her zaman komutla doğrulayıp tarih yazmak |

## Dersler

- Kaynağı olmayan bilgiyi yazma; "doğrulanmadı" de.
- Yönlü şemaları (bağımlılık gibi) kaynakla karşılaştır.
- Her ignore kuralını ve her bağlantıyı bir araçla doğrula.
- Push etmeden önce görünürlüğü ve içeriği kontrol et.
