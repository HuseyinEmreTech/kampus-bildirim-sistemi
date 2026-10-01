---
title: Skill, Plugin ve Araç Kullanım Günlüğü
durum: Güncel
son-guncelleme: 2026-09-30
---

# Skill, Plugin ve Araç Kullanım Günlüğü

← [İndeks](../00-index.md) · Ne oldukları ve neden kullanıldıkları: [Skill kataloğu](skill-katalogu.md)

Her hafta hangi Skill'in **nerede, neden** kullanıldığı ve **sonucu** burada tutulur. Yalnızca gerçekten kullanılanlar yazılır.

## Kullanılan araçlar

| Araç | Model | Ne için |
| --- | --- | --- |
| Claude Code (terminal) | Claude Haiku 4.5, Claude Sonnet 5.x | Doküman taslakları, notların düzenlenmesi, inceleme |
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

## Planlanan

| Öğe | Amaç | Ne zaman | Durum |
| --- | --- | --- | --- |
| Proje standartları Skill'i | Git akışı, isimlendirme, doküman biçimi, test ve SonarQube kurallarını ajana vermek | Kod reposu açılınca; `writing-skills` ile yazılıp test edilecek | Planlandı |
| Kod inceleme ajanı | PR'ı proje standartlarına göre denetlemek | Skill'den sonra | Fikir |
| TDD, doğrulama ve inceleme Skill'leri | Kodlama aşamasında disiplin | İlk kod PR'ı | Planlandı ([katalog](skill-katalogu.md)) |

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
