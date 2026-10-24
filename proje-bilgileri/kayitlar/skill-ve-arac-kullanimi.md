---
title: Skill, Plugin ve Araç Kullanım Günlüğü
durum: Güncel
son-guncelleme: 2026-10-24
---

# Skill, Plugin ve Araç Kullanım Günlüğü

← [İndeks](../00-index.md) · Ne oldukları ve neden kullanıldıkları: [Skill kataloğu](skill-katalogu.md)

Her hafta hangi Skill'in **nerede, neden** kullanıldığı ve **sonucu** burada tutulur. Yalnızca gerçekten kullanılanlar yazılır.

## Kullanılan araçlar

| Araç | Model | Ne için |
| --- | --- | --- |
| Claude Code (terminal) | Claude (raporlarda Haiku 4.5, Sonnet 5.x, Opus 5.5) | Kod, test, doküman taslakları, inceleme |
| OpenCode (terminal) | DeepSeek V4.1 Flash | PR inceleme/birleştirme, doküman, Sonar teşhisi, token sayımı |
| Gemini | - | İlk sunucu iskeleti ve SonarCloud kurulumu (#19 öncesi) |
| GitHub Copilot (VS Code) | gpt-6-luna | Responsive bildirim listesi (#22) |
| Obsidian | - | Doküman vault'u |
| GitHub CLI (`gh`) | - | Repo görünürlüğü ve durumunu kontrol etme |
| Web araması (Claude Code aracı) | - | Bir aracın gerçek olup olmadığını doğrulama (Graphify) |

## Kurulu eklentiler

| Eklenti | Sürüm | Ne içerir | Projede |
| --- | --- | --- | --- |
| `obsidian-skills` | 1.0.1 | 5 Obsidian Skill'i | `obsidian-cli`, `obsidian-bases` kullanıldı |
| `superpowers` | 6.4.1 (6.3.0 eski kopya diskte) | 15 süreç Skill'i | `brainstorming` kullanıldı, `using-superpowers` otomatik |
| `ponytail` | 4.8.4 | 6 sadelik Skill'i | Otomatik "full" modda etkin |
| Ruflo (MCP sunucusu) | - | Çoklu ajan, bellek, komut aileleri | Projede kullanılmadı |

## Otomatik etkin olanlar

Çağırmasak da yanıtları etkiledikleri için dürüstlük gereği yazılır:

| Ne | Nasıl etkin | Etkisi |
| --- | --- | --- |
| `ponytail` (full) | Oturum başlangıç kancası | Basit çözümü ve kısa yanıtı zorlar; gereksiz karmaşıklığı azaltır |
| `using-superpowers` | Oturum başlangıç kancası | İlgili Skill varsa yanıttan önce çağrılmasını şart koşar |

## Haftalık kullanım

### Hafta 2 (25 Eylül 2026)

| Tarih | Skill / araç | Nerede | Neden | Sonuç | Sorun |
| --- | --- | --- | --- | --- | --- |
| 2026-09-25 | `obsidian-bases` | Kişisel ders notları | Notları hafta ve konuya göre listeleyen görünümler | Görünümler kuruldu | Yok |
| 2026-09-25 | `obsidian-cli` | Kişisel ders notları | Vault'a bağlanıp notları doğrulamak | Vault doğrulandı | Yok |
| 2026-09-25 | Claude Code | Ders deposunu inceleme | Hocanın doküman biçimini ve yöntemini çıkarmak | Biçim çıkarıldı | Uydurma bağlantı ([hata kaydı](hata-kayitlari.md)) |

### Hafta 3 (30 Eylül 2026)

| Tarih | Skill / araç | Nerede | Neden | Sonuç | Sorun |
| --- | --- | --- | --- | --- | --- |
| 2026-09-30 | `obsidian-cli` | `proje-bilgileri` vault taraması | Çözülemeyen bağlantı, yetim ve çıkışsız dosyaları kanıtlı bulmak | `adr/`, `haftalik/` klasör bağlantıları ve yetim günlük bulundu; düzeltildi, sonrasında sıfır | Klasöre bağlantı Obsidian'da çözülmüyor: dosyaya bağlantı verildi |
| 2026-09-30 | `obsidian-cli` | Vault kayıtları ve yeniden tarama | Obsidian'daki vault yollarını doğrulamak ve düzeltmek; bağlantı ve yetim taraması | Vault yolları düzeltildi; tüm vault'larda çözülemeyen bağlantı yok | Obsidian URI ile vault kaydı çalışmadı; yapılandırma dosyası yedekli düzenlendi |
| 2026-09-30 | `superpowers:brainstorming` | Proje önceliklerinin tartışılması | Uygulamadan önce niyeti ve fikirleri netleştirmek | Öncelik listesi ve izleme sistemi fikri | Yok |
| 2026-09-30 | Web araması | Graphify değerlendirmesi | Aracın gerçek olup olmadığını ve ne yaptığını doğrulamak | Araç gerçek; tanıtım iddiaları doğrulanmadı | Kaynaklar tanıtım yazıları; doğrudan doğrulanamadı |
| 2026-09-30 | Podman, SonarQube Web API | SonarQube doğrulaması | Yeni konteyner başlatıp durumu ve dil/kural listesini sorgulamak | SonarQube çalışıyor; Dart dili yok (0 kural) | Yok; deneme konteyneri silindi |
| 2026-09-30 | Claude Code | Doküman yazımı ve kayıt sistemi | Kapsam, mimari, domain, API, kayıt dosyaları | `proje-bilgileri` ilk sürümü | 4 hata kaydedildi ([hata kayıtları](hata-kayitlari.md)) |

### Hafta 4 (5-11 Ekim 2026)

Bu hafta için günlük rapor yok; araç/skill kaydı tutulmadı. Uydurulmadı.

### Hafta 5 (12-18 Ekim 2026)

Not: Bu haftanın günlük raporlarında **skill adı** yazılmamış; tablo araç/model düzeyinde ve raporlardaki kanıta dayanıyor.

| Tarih | Skill / araç | Nerede | Neden | Sonuç | Sorun |
| --- | --- | --- | --- | --- | --- |
| 2026-10-12 | Claude Code (Claude) | #17 şema planı, `compose.yaml`, V1 şema taslağı, Rule 02 SQL eşzamanlılık denemesi | Plan ve taslak üretimi | Plan ve dosyalar; "onaysız push yok" kuralı kondu | Onaysız push |
| 2026-10-15 | Gemini | Shelf sunucu iskeleti, `/health`, CORS; SonarCloud kurulumu | Sunucu iskeleti | İskelet çalıştı | Ortak dosyalara (CI, Sonar, `pubspec.yaml`) kapsam dışı dokunuldu |
| 2026-10-15 | Claude Code (Claude) | `Database` sınıfı ve testleri, `postgres` paket ayarları | Veritabanı katmanı | Kod ve testler | Yok |
| 2026-10-15 | Claude Code (Claude) | #21 liste ve oluşturma ekranı: plan, test (önce kırmızı), kod | Mobil arayüz | 2 PR; 314 satır 300'ün altına indirildi | Plan gösterilmedi, yazdırılıp onaylandı |
| 2026-10-16 | Claude Code (Claude) | Dal güncelleme/çakışma çözme, açık PR hata ve güvenlik incelemesi | Bakım | PR'lar güncellendi | Yok |
| 2026-10-16 | Claude Code (Claude) | Oturum durumu (`AuthController`, `Session`): plan, test, kod | Mobil auth | Testler kırmızıdan yeşile | Yok |
| 2026-10-17 | Claude Code (Claude) | Rebase, test önce, ölçüm hazırlığı, hata incelemesi | Bakım/kalite | V5'teki NULL/CHECK açığını test yakaladı | Yok |
| 2026-10-17 | Claude Code (Claude) | #19 auth planı, kod, testler; istek sınırı, güvenlik başlıkları, JSON günlük | Sunucu auth | 4 dal (PR #67, #80, #81, #82) | İlk denemede eksik import ve test dönüş tipi hatası |
| 2026-10-18 | Claude Code (Claude) | Arayüz sınıfını test önce yazma, Caddy/günlük ayarları, kurtarma tatbikatı, rehber | Altyapı | Tatbikat ve rehber | Yedek dosya izinleri (`chmod 600` gerekti) |
| 2026-10-18 | GitHub Copilot (gpt-6-luna) | #22 responsive bildirim listesi ve widget testleri | Mobil arayüz | Kod ve testler; kapsam dışı demo verisi kaldırıldı | İlk testte import ve seçici sorunları |

### Hafta 6 (19-25 Ekim 2026)

| Tarih | Skill / araç | Nerede | Neden | Sonuç | Sorun |
| --- | --- | --- | --- | --- | --- |
| 2026-10-19 | Claude Code (Claude) | #20 hata eşleme, listeleme ve üstlenme uçları; #80-#82 PR açıklamaları; SonarCloud hatası | Sunucu API | Kod ve testler; PR'lar | 300 satır sınırı için iş bölündü |
| 2026-10-21 | Claude Code (Claude) | #77/#78'in 2. parçaları, Chrome'da çalıştırma, günlük rapor | Mobil | PR #97, #98 hazırlandı | `lib/ortak/` taşımasından çakışma |
| 2026-10-21 | OpenCode (DeepSeek V4.1 Flash) | PR inceleme ve birleştirme, issue güncelleme, doküman/ADR, token kaydı | Süreç | Birleşmeler ve dokümanlar; oturum tokenı 10.741.727 | Yok |
| 2026-10-24 | OpenCode (DeepSeek V4.1 Flash); `systematic-debugging`, `github-code-review`, `using-superpowers` (otomatik) | PR #97-#99 denetimi; SonarCloud kapsam hatasının teşhisi ve düzeltmesi; PR şablonu güncellemesi | Kalite ve süreç | #97-#99 birleşti; #100, #101, #102 PR'ları; eksikler PR yorumlarına yazıldı | Eksik klasör taramayı kırdı; `contracts/test` boş olduğu için CI'da yok |

## Planlanan

| Öğe | Amaç | Ne zaman | Durum |
| --- | --- | --- | --- |
| Proje standartları Skill'i | Git akışı, isimlendirme, doküman biçimi, test ve SonarQube kurallarını ajana vermek | Kod reposu açılınca; `writing-skills` ile yazılıp test edilecek | Planlandı |
| Kod inceleme ajanı | PR'ı proje standartlarına göre denetlemek | Skill'den sonra | Kullanıldı (2026-10-24, `github-code-review` ile #97-#99 denetimi) |
| TDD, doğrulama ve inceleme Skill'leri | Kodlama aşamasında disiplin | İlk kod PR'ı | Test önce pratikte kullanıldı (raporlar); skill adı kaydedilmedi |

## Değerlendirilen araçlar

### Graphify (bilgi grafiği)

| | |
| --- | --- |
| Ne | Kod tabanını, dokümanları, SQL şemalarını ve yapılandırmaları sorgulanabilir bir bilgi grafiğine çeviren, Claude Code, Cursor, Codex ve Gemini CLI için Skill olarak gelen araç ([GitHub](https://github.com/Graphify-Labs/graphify)) |
| Neden ilgi çekici | LLM'lerin projeyi daha iyi ve daha az token ile anlaması; derste işlenen Graph RAG ve Knowledge Graph kavramıyla örtüşüyor |
| Neden şimdi değil | Proje henüz doküman aşamasında; graf için yeterli kod yok. Yapılandırılmış dokümanlar zaten iyi bir bağlam sağlıyor |
| Dikkat | Araç bir Skill ve kanca (PreToolUse hook) ekliyor; kaynağının güvenilirliği ve güncelliği kurulmadan önce kontrol edilmeli. Tanıtım yazılarındaki token tasarrufu iddiaları doğrulanmadı |
| Karar | Kod oluştuktan sonra ayrı bir feature branch'inde denenecek; token kullanımı ölçülüp bu dosyaya yazılacak. Benimsenirse ADR yazılır |
| Durum | Değerlendiriliyor, kurulmadı |

## Yeni hafta ekleme şablonu

```markdown
### Hafta N (GG Ay YYYY)

| Tarih | Skill / araç | Nerede | Neden | Sonuç | Sorun |
| --- | --- | --- | --- | --- | --- |
```
