---
title: 25-26 Ekim 2026 - PR İnceleme Notları
durum: Güncel
son-guncelleme: 2026-10-26
---

# 25-26 Ekim 2026 - PR İnceleme Notları

← [İndeks](../00-index.md)

Açık 21 PR tek tek incelendi; her birine GitHub yorumu yazıldı. Ölçütler: [AGENTS.md](../../AGENTS.md) (paket/kod/git/doküman kuralları), PR şablonu (yapay zeka kullanımı alanları), [AI kullanımı](../09-ai-usage.md), testler ve CI/SonarCloud durumu.

## Kime ne yazıldı

### Cagdas3307 — sunucu zinciri (#110-#127, 17 PR)

| PR | Konu | Sonuç |
| --- | --- | --- |
| #110 | Rate limit + güvenlik başlıkları | **Değişiklik istendi** |
| #111 | JSON istek günlüğü | Onaylandı |
| #112 | `GET /api/users/me` | Onaylandı + katman sorusu |
| #113 | Denetim kaydı | Onaylandı |
| #114 | OpenAPI tanımı | Onaylandı |
| #115 | Hata eşleme | Onaylandı |
| #116 | Bildirim listesi uçları | Onaylandı (bağlama #17'de) |
| #117 | Üstlenme ucu | Onaylandı |
| #118 | Multipart yardımcısı | **Değişiklik istendi** |
| #119 | Çözme ucu | Onaylandı |
| #120 | Fotoğraf yanıtları ortak dosya | Onaylandı |
| #121 | Bildirim oluşturma ucu | Onaylandı |
| #122 | Bina listesi | Onaylandı |
| #123 | Bildirimlerim / okundu | Onaylandı |
| #124 | Gövde boyut sınırı (413) | Onaylandı + not |
| #125 | Günlük rapor + plan | Onaylandı |
| #126 | C# istatistik servisi | Onaylandı + 3 not |
| #127 | C# CSV dışa aktarma | Onaylandı |

### yamanmurat761 — #128

| PR | Konu | Sonuç |
| --- | --- | --- |
| #128 | #99 yapay zeka kaydı, 24 Ekim raporu, Sonar S7721 düzeltmesi | Onaylandı |

### muberrayener — #129

| PR | Konu | Sonuç |
| --- | --- | --- |
| #129 | Python rapor dışa aktarma servisi + Sonar entegrasyonu | **Değişiklik istendi** |

### KeremC23 — #132

| PR | Konu | Sonuç |
| --- | --- | --- |
| #132 | E2E test iskeleti, seed betiği, rehber | **Değişiklik istendi** |

## Gerekçeler

### #110 - Değişiklik istendi (güvenlik)
- `clientIp` yalnızca doğrudan bağlantı bilgisini okuyor; proxy/CDN arkasında gerçek istemci IP'si kaybolur, istek sınırı atlatılabilir.
- Middleware sırası `securityHeaders() → corsHeaders()`: CORS başlıkları güvenlik başlıklarını ezebilir. Doğru sıra CORS → güvenlik → limit.
- HSTS yalnızca HTTPS'te işler; geliştirme HTTP'sinde etkisiz, not düşülmeli.
- Giriş yolu kontrolünde baştaki `/` tutarlılığı doğrulanmalı.

### #112 - Katman sorusu
`UserRepositoryImpl` doğrudan `server.dart` içinde kullanılıyor. Sunucu paketi tüm paketlere bağlanabilir ama iş kuralı application katmanında olmalı. Basit sorgu olduğu için kabul edilebilir; gerekçe PR'da yazılmalı.

### #118 - Değişiklik istendi (paket kuralı)
`mime` paketi `pubspec.yaml`'a **doğrudan bağımlılık** olarak eklenmiş. AGENTS.md: "Yeni paket ekleme: gerekirse dur ve sor." `mime` 2.1.0 zaten dolaylı bağımlılıktı; yine de doğrudan ekleme onayı gerekir.

### #124 - Onaylandı + not
`BodyTooLarge` istisnası akışı kesmek için kullanılıyor; middleware içinde yakalanıp 413'e çevrildiği ve uç kodlarına ulaşmadığı için AGENTS.md'deki "istisnayla akış kontrolü yok" kuralıyla çelişmiyor. Not düşüldü.

### #126 - Onaylandı + 3 not
- `services/rapor-istatistik/` klasör yerinin Python servisiyle ortak kuralı yok.
- `dotnet test` CI işi ve `compose.yaml` eklenmesi ADR-04'e göre entegrasyon sahibinde; bu PR'da yok.
- ADR-04 hâlâ "Önerildi"; kapsam netleşince servis büyütülebilir.

### #128 - Onaylandı
#99'un eksik yapay zeka kaydı tamamlanmış, 24 Ekim raporu token kayıtlı, S7721 (`toResult` dış kapsam) düzeltilmiş ve tarayıcı testleri 16/16 geçmiş. JS kapsamı (LCOV) bilinen borç olarak not edilmiş.

### #129 - Değişiklik istendi (CI/entegrasyon)
- PR `sonar.yml` ve `ci.yml` değiştirmiş ama CI çalışmamış; `sonar-project.properties` güncellendiği için Sonar taraması tetiklenmeliydi.
- Ekran görüntüleri README'de GitHub eki olarak duruyor; commit'e kalıcı girmiyor.
- CSV dışa aktarma gerçek çekirdek API ile uçtan uca doğrulanmamış.
- SonarCloud Python kapsamı ve kalite kapısı sonucu doğrulanmamış.

### #132 - Değişiklik istendi (şablon/doküman)
- PR şablonunda "Neden bu araç/model", "Kullanılan skill", "Harcanan token" alanları eksik.
- 4 dosyada dosya sonu yeni satırı yok.
- `conftest.py` diff'te `patch: null`; içeriği doğrulanmalı.
- Python + pytest + requests yeni ekosistem; AGENTS.md'ye göre onay notu gerekir.
- CI'a Python test işi eklenmemiş (onay bekliyor denmiş).

## Açık işler (inceleme sonrası)

| İş | Kime | Not |
| --- | --- | --- |
| #110 güvenlik düzeltmeleri | Cagdas3307 | Proxy IP, sıra, HSTS notu |
| #118 `mime` onayı | Ertuğrul / Hüseyin | Onay PR yorumuna eklensin |
| #129 CI + uçtan uca test + Sonar doğrulama | muberrayener | Ekran görüntüleri repo'ya |
| #132 şablon + dosya sonu + Python onayı + CI | KeremC23 | `conftest.py` doğrulanacak |
| #126 klasör yeri / ADR-04 durumu | Cagdas3307 | Ayrı takip |

## İnceleme oturumu

- Araç: OpenCode ajanı; GitHub CLI ve Obsidian CLI kullanıldı.
- Yararlanılan skill'ler: `github-code-review` (PR inceleme), `systematic-debugging` (kanıta dayalı teşhis), `obsidian-cli` (bu notun oluşturulması ve vault doğrulaması).
- Bulgular kanıta dayandırıldı: dosya diff'leri, PR gövdeleri, CI/Sonar durumu.
- Künye bilgisi PR yorumlarındakiyle aynıdır.
