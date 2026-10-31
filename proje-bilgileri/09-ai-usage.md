---
title: Yapay Zeka Kullanımı
durum: Güncel
son-guncelleme: 2026-10-31
---

# Yapay Zeka Kullanımı

← [İndeks](00-index.md)

Yapay zeka çıktısı taslak kabul edilir; okunur, doğrulanır ve gerektiğinde düzeltilir. Yalnızca gerçekten kullanılanlar yazılır.

## Nerede ne tutulur

| Konu | Dosya |
| --- | --- |
| Her Skill'in ne olduğu, neden var olduğu ve projede neden kullanıldığı | [Skill kataloğu](kayitlar/skill-katalogu.md) |
| Haftalık kullanım: hangi Skill, nerede, neden, sonuç; eklentiler; değerlendirilen araçlar | [Skill, Plugin ve araç kullanım günlüğü](kayitlar/skill-ve-arac-kullanimi.md) |
| Yapay zekanın yanıldığı yerler ve düzeltmeler | [Hata kayıtları](kayitlar/hata-kayitlari.md) |
| PR başına kullanım (araç, neden, skill, prompt, token) ve review notu | PR açıklaması (şablondaki "Yapay zeka kullanımı" bölümü) |
| Ekipteki herkesin yapay zeka aracına verilen kurallar | [AGENTS.md](../AGENTS.md) |
| Yapay zeka ile nasıl çalışıyoruz | [Başlangıç rehberi](ekip/00-baslangic-rehberi.md#5-yapay-zeka-ile-nasıl-çalışıyoruz) |

## Çalışma ilkeleri

- Yapay zekaya proje bağlamı verilir ([kapsam](01-project-scope.md#7-ölçek-ve-kısıtlar-proje-bağlamı)); ölçek ve sınırlar bilinsin, gereksiz karmaşıklık üretilmesin.
- Küçük parçalar istenir; tek seferde büyük üretim yapılmaz.
- Çıktının **özeti ve varsayımları** istenir ve önce o okunur.
- Sırlar, şifreler ve kişisel veri prompt'lara girmez.
- Hata verirken log, exception ve değerler yapıştırılır.
- Basit işler elle yazılır; yapay zeka karmaşık ve tekrarlayan işlerde kullanılır.
- Anlaşılmayan kod projeye alınmaz.
- Yapay zekanın yazdığı test ve ADR taslaktır; satır satır incelenir.

## Token kullanımı

Her günlük raporda o gün yapay zeka araçlarında harcanan **yaklaşık token** yazılır. Amaç maliyeti ve verimi görmek, hocaya somut veri sunmak.

- Araçta oturum/toplam token görünüyorsa o değer yazılır.
- Görünmüyorsa tahmin edilir ve **"tahmini"** olarak işaretlenir.
- Birden çok araç kullanıldıysa araç adıyla birlikte yazılır: `Claude Code ~120k`, `Copilot ~15k`.
- Sır veya kişisel veri içeren prompt'lar yazılmaz; yalnızca miktar.

## Review süresi

Yapay zekanın ürettiği işin okunup doğrulanması süre alır. Her Pull Request için ölçülür.

| PR | Üretim süresi | Review süresi | Not |
| --- | --- | --- | --- |
| | | | Henüz PR yok |

## Önemli prompt'lar

| Tarih | Prompt (kısa) | Bağlam | Sonuç ve yorum |
| --- | --- | --- | --- |
| 2026-10-31 (PR incelemesi) | "Kampüs bildirim sistemindeki belirli PR'ları incele; AGENTS.md + 11-kod-mimarisi + 05-api-design ölçütleriyle diff'i tam oku; TÜRKÇE review yorumu hazırla ama GitHub'a _hiçbir şey gönderme_; sonucu her PR için ayrı dosyaya yaz (karar: onaylar/yorum/değişiklik iste + uygunluk maddeleri). Yeni dış paket ekleme, paket bağımlılık ihlali, parametresiz SQL, `default` dalı, `print`, test yokluğu, sır sızıntısı bulgularını ayrı ayrı işle." | 32 açık PR / 4 paralel temsilci; temsilciye verilen bağlam: diff'in tamamı, PR gövdesi, ölçüt dokümanları | 32 review yorumu hazırlandı; gönderiden önce insan kontrolü yapıldı; 23 approve / 8 yorum / 1 değişiklik iste. Araca güvenilen: dosya okuma + kural eşleme; gönderim elle |
| 2026-10-31 (karar doğrulama) | "Yeni commit onayı düşürünce PR'ın kendi koduna değişti mi bak: iki commit SHA arasındaki dosya farkı, PR'ın kendi dosya yolları ile compare'da değişen yolların kesişimi" | #142 conflict-merge sonrası | Kod değişmediği gözlendi, PR yeniden onaylandı; `gh api compare` ile dosya düzeyde kanıt |
