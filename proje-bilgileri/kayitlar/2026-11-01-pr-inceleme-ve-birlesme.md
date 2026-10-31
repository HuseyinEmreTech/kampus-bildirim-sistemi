---
title: 2026-11-01 PR İnceleme ve Birleştirme Turu
durum: Güncel
son-guncelleme: 2026-11-01
---

# 2026-11-01 PR İnceleme ve Birleştirme Turu

← [İndeks](../00-index.md) · [Geliştirme süreci](../08-development-process.md) · [Hata kayıtları](hata-kayitlari.md)

31 Ekim-1 Kasım 2026'da depodaki açık PR'lar tek tek incelendi ve birleştirildi. Ölçütler: [AGENTS.md](../../AGENTS.md), [kod mimarisi](../11-kod-mimarisi-ve-korumalar.md), [API tasarımı](../05-api-design.md).

## Sonuç

- 40'tan fazla PR birleşti; kalan açık PR yok.
- İlk tur (110-144): 23 onay, 8 yorum, 1 değişiklik iste (129). İkinci tur (145-158): Flutter v2 seti (145-151, 155), C# (126-127), Python (129), E2E (132), kurtarma PR'ları (152, 154, 157) ve süreç/altyapı (153, 156, 158).
- 4 issue kapatıldı (#17, #18, #20, #90); 3 issue açık kaldı (#21, #93, #94); 2 yeni issue açıldı (#159 detay ucu, #160 bina filtresi).

## Yapılan teknik işler

- **Zincir rebase'leri:** Squash birleşmelerden sonra taban dalları çakıştığı için 113-124, 138, 148, 129, 132 `git rebase --onto origin/main <eski-taban>` ile taşındı; PR'ın kendi dosyaları korundu, yazarlık korundu, force push `--force-with-lease` ile yapıldı.
- **Kod düzeltmeleri:** 116'da geçersiz `status` 400'e çekildi; 121'de geçersiz `locationSource` 400 döndürüyor; 123'te `FakeNotifications` `unreadOnly` uyumu ve doküman biçimi; 132'ye gerçek `conftest.py`; 157'de demo testine zorunlu `photo`.
- **Doküman:** `services/` yapısı ve C# servisi (11-kod-mimarisi + teknoloji kaydı), ADR-04 uygulama notu, Python ve E2E teknoloji satırları.
- **Süreç:** `scripts/pr-birlesme-kontrolu.sh` (dalı base alan açık PR varsa engeller), CI'da orphan dal denetimi, `08-development-process.md` yığın PR bölümünün güncellenmesi.

## Yaşanan sorunlar

| Sorun | Etki | Çözüm / önlem |
| --- | --- | --- |
| `--delete-branch` taban dalını silince #112 ve #114 otomatik kapandı | Yeniden açılamadı; içerik #152/#154 olarak kurtarıldı | Script + CI + hata kaydı (2026-11-01) |
| #132 dalı `main` ile ortak geçmişe sahip değildi (orphan) | GitHub çakışma gösterdi | Dal `main` üstünde tek commit'e yeniden yazıldı; CI'a orphan denetimi |
| #150 testi #145 sonrası zorunlu `photo` alanını içermiyordu | `main` CI kırıldı | #157 ile düzeltildi |
| Sahibi olunan PR'larda GitHub kendi kendini onaylamayı engelledi | 153, 156, 157, 158 | `--admin` ile birleştirildi, kayda geçti |

## Açık işler

- #159 `GET /api/reports/{id}` detay ucu; mobil detay kaynağı
- #160 `GET /api/reports?buildingId=` filtresi
- #21 uygulama kabuğu (`main.dart`), gerçek HTTP kaynakları, konum alanının forma bağlanması, cihaz testi
- #93 gerçek sunucuya karşı E2E ve CI işi
- #94 contracts DTO'ları + deploy
- C# servisi için CI'a `dotnet test` işi
- Demo backend'in teslim öncesi kaldırılması/gizlenmesi

## Yapay zeka kullanımı

| Alan | Değer |
| --- | --- |
| Araç / model | OpenCode, `GLM-5.3 Flash` (`opencode-go/glm-5.3-flash`) |
| Yöntem | Her PR için gövde + tam diff + önceki yorumlar; 4 paralel inceleme temsilcisi ilk turda diff'leri okudu; gönderim insan tarafından yapıldı |
| Prompt (inceleme) | "PR'ı depo kurallarına göre incele; uygunluk maddeleri, dosya/satır bulguları ve karar yaz; Türkçe yorum hazırla; GitHub'a hiçbir şey gönderme" |
| Prompt (birleştirme) | "Her PR'ı tek tek ele al; tabanı main'e getir, içeriği doğrula, onay ve kontroller yeşilse birleştir" |
| Doğrulama | Yorumlar ve merge'ler gönderilmeden önce insan okudu; force-push öncesi `git diff` karşılaştırması |
