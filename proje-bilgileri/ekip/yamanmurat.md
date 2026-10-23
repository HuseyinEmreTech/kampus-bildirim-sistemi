---
title: Murat Yaman - Kişisel Plan
durum: Taslak
son-guncelleme: 2026-10-24
---

# Murat Yaman (@yamanmurat761) - Kişisel Plan

← [Ekip ve yol haritası](../10-ekip-ve-yol-haritasi.md) · [İndeks](../00-index.md)

## Rol

**Web istemcisi.** Ayrı web uygulaması (HTML/CSS/JS) çekirdeğin REST API'sini tüketir. Ayrıca SQL/veritabanı incelemesi ve sorgu kontrolü.

## Güçlü alanlar

- C++, C#, HTML
- MariaDB (projede PostgreSQL kullanılıyor; SQL bilgisi doğrudan geçerli)

## İlk iki hafta

- [ ] Repoyu klonla, `.env.example` → `.env`, `compose.yaml` ile PostgreSQL'i çalıştır.
- [ ] [Başlangıç rehberi](00-baslangic-rehberi.md) ve [ADR-04](../adr/04-cok-dilli-web-ve-servisler.md) oku.
- [x] Web istemcisi iskeleti: giriş, token saklama, 401 yönlendirme (#90).
- [x] Bildirim listesi: kategori/durum/bina filtreleri + sayfalama (#90).
- [ ] SQL incelemesi: migration ve sorguları gözden geçir; yavaş sorgu notu çıkar.

## Sınırlar

- **Dokunulmayacak:** `packages/` (Dart çekirdek), `db/migrations/` (onaysız), `packages/app/`.
- **Yeni paket/bağımlılık:** önce issue'da sor.
- **Sır yok:** `.env`, token, gerçek öğrenci verisi commit'e girmez.

## Kayıt

- Her çalışılan gün [günlük rapor şablonu](../Templates/gunluk-rapor.md) ile `ekip/raporlar/yamanmurat/YYYY-AA-GG.md` yaz.
- Raporda **harcanan token** da yazılır ([09 Yapay zeka](../09-ai-usage.md#token-kullanımı)).
