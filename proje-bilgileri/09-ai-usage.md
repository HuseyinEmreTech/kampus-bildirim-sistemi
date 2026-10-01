---
title: Yapay Zeka Kullanımı
durum: Güncel
son-guncelleme: 2026-09-30
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
| PR başına kullanım, prompt ve review notu | PR açıklaması (şablondaki "Yapay zeka kullanımı" bölümü) |
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

## Review süresi

Yapay zekanın ürettiği işin okunup doğrulanması süre alır. Her Pull Request için ölçülür.

| PR | Üretim süresi | Review süresi | Not |
| --- | --- | --- | --- |
| | | | Henüz PR yok |

## Önemli prompt'lar

| Tarih | Prompt (kısa) | Bağlam | Sonuç ve yorum |
| --- | --- | --- | --- |
| | | | |
