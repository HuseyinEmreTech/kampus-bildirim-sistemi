---
title: Hata Kayıtları
durum: Güncel
son-guncelleme: 2026-10-17
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
| 2026-10-15 | PR #33 (sunucu iskeleti) | Görev "yalnızca health check" iken paylaşılan CI/Sonar dosyaları değiştirildi: `.github/workflows/sonar.yml` silindi, `sonar-project.properties` kişisel SonarCloud projesine (`cagdas3307_...`) çevrildi, `ci.yml`'den "Biçim" adımı kaldırıldı, `campus_server` paketi `server` olarak yeniden adlandırıldı ve `packages/server/pubspec.lock` eklendi | Ortak yapılandırmanın görev kapsamına dahil edilmesi; kişisel taramayı çalıştırma ihtiyacı | PR diff'i incelenirken; ayrıca zorunlu `SonarCloud Code Analysis` kontrolünün hiç üretilmemesi | Yorumla request-changes istendi: dosyaları geri getirip kapsamı `bin/server.dart` ile sınırlaması istendi. `main` koruması gereği PR BLOCKED kaldı | Paylaşılan CI/Sonar dosyalarına görev kapsamı dışında dokunma kuralı ([kod mimarisi ve korumalar](../11-kod-mimarisi-ve-korumalar.md#31-paylaşılan-ci-ve-sonar-dosyaları)); PR diff'ini bu dosyalar için ayrıca kontrol etmek |
| 2026-10-15 | PR #34 (Database) | SonarCloud kalite kapısı "yeni kod kapsamı %14.3 (< %80)" ile kırmızı | `Database`'in gövdesi yalnızca `@Tags(['db'])` testleriyle kaplanmıştı; bu testler CI'da (`DATABASE_URL` yok) atlanıyor | SonarCloud kalite kapısı mesajı | Yorumla request-changes istendi: CI'da koşan birim testler eklemesi istendi | Yeni kod kapsamını CI'da koşan testlerle sağlamak; yalnızca `db` etiketli testlere güvenmemek |
| 2026-10-17 | Yığın PR #60 (create) | Base bloğu (`resolved` dalı) `--delete-branch` ile silinince GitHub #60'ı otomatik kapattı; PR kapalıyken force-push edildiği için "branch was force-pushed or recreated" hatasıyla yeniden açılamadı | Yığın PR'da base dalını silmenin çocuğu kapatacağının bilinmemesi | PR zaman çizelgesinde `base_ref_deleted` → `closed`; `gh pr reopen` hatası | Dal, PR'ın kayıtlı head'ine geri alındı, PR yeniden açıldı, sonra rebase'li hali push edildi | Yığın PR'da alt PR birleşmeden **önce** çocuğun base'ini `main`'e retarget etmek ([yığın PR süreci](2026-10-17-yigin-pr-birlesme-sureci.md)) |
| 2026-10-17 | Yedek PR #69 (create) | Base dalı silinen #60 yerine lead'in kendi açtığı yedek PR #69 birleşemedi | Yazarın kendi PR'ını onaylayamadığı kuralının gözden kaçması | `gh pr review` hatası ("Can not approve your own pull request") | Yedek PR kapatıldı, asıl PR (#60) kurtarıldı | Değiştirme/yedek PR'ı başka bir üye açsın; ya da asıl PR kurtarılsın |

## Dersler

- Kaynağı olmayan bilgiyi yazma; "doğrulanmadı" de.
- Yönlü şemaları (bağımlılık gibi) kaynakla karşılaştır.
- Her ignore kuralını ve her bağlantıyı bir araçla doğrula.
- Push etmeden önce görünürlüğü ve içeriği kontrol et.
- Paylaşılan CI/Sonar dosyalarına görev kapsamı dışında dokunma. Özellikle `.github/workflows/sonar.yml` **silinemez**: zorunlu `SonarCloud Code Analysis` kontrolünü yalnızca o üretir, silinirse hiçbir PR birleşemez.
- Yeni kodun test kapsamını CI'da gerçekten koşan testlerle sağla; yalnızca `@Tags(['db'])` gibi CI'da atlanan testlere güvenme.
- **Yığın PR:** alt PR squash'lanmadan önce çocuğun base'ini `main`'e al; base dalını silmek çocuğu otomatik kapatır. Alt PR birleşince üst dalı `main`'in üzerine rebase et (squash-only + linear history).
- **Kendi PR'ını onaylayamazsın:** değiştirme/yedek PR'ları başkası açsın; force-push onayı düşürür, birleştirmeden önce yeniden onayla ve zorunlu kontrolü bekle.
- **Çakışmada iki bağımsız özelliği de koru:** aynı dosyaya dokunan iki ayrı iş birleşirken birini diğerine feda etme.
- **İnceleme notları:** `required_conversation_resolution` açıkken inline yorum merge'i bloklar; notları inceleme gövdesine yaz.
