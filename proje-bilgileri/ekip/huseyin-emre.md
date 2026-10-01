---
title: "Plan: Hüseyin Emre"
durum: Güncel
son-guncelleme: 2026-10-02
---

# Plan: Hüseyin Emre (teknik lider)

← [Ekip ve yol haritası](../10-ekip-ve-yol-haritasi.md) · [Başlangıç rehberi](00-baslangic-rehberi.md)

**Sorumluluk:** `domain`, `application`, `contracts` paketleri; mimari test, CI, `AGENTS.md`; her kural için kabul testlerini görevden **önce** yazmak; tüm PR'ları incelemek; haftalık kayıt ve ADR'lar.

**Kural:** Başkasına atanacak her görevin issue'su, kabul testi ve arayüzü (imzalar) o hafta **Pazartesi** hazır olur. Diğerleri beni beklememeli.

**Darboğaz riski:** Her PR benden geçiyor. Önlem: inceleme günde iki kez (öğle, akşam); hafta 6'dan sonra `infrastructure` PR'larını Ertuğrul, `app` PR'larını Murat da onaylayabilir (CODEOWNERS yalnızca çekirdeği bana bağlar).

## Haftalık plan

### Hafta 3 (28 Eyl - 4 Eki)
- Git geçmişini temiz başlat: `main`'den `docs/proje-bilgileri` branch'i, yalnızca dokümanlar, README, `.gitignore`, `AGENTS.md`, `CLAUDE.md`.
- GitHub: `main` koruması (2 Ekim'de kuruldu), etiketler, milestone'lar (Hafta 03-15), Projects panosu, hafta 3-4 issue'ları.
- Yusuf Ekenel'i davet et (GitHub adı alınınca).
- `ekip/` dosyalarını ve ilk PR görevini (herkes ilk günlük raporunu yazar) duyur.

### Hafta 4 (5 - 11 Eki)
- **Repo iskeleti** ([uygulama planı](../planlar/2026-10-02-repo-iskeleti.md)): workspace, 6 paket, mimari test, CI, `CODEOWNERS`, PR ve issue şablonları.
- `domain`: `ReportId`, `UserId`, `Role`, `Category`, `ReportStatus`, `Location` (kaynak: `gps` / `building`), `Photo`, `Actor`, `DomainError`, `Report.create`; Rule 05, 06 (sınır nesnesi `CampusBounds`), 07 için birim testleri.
- Murat'ın `contracts` görevi için DTO listesini issue'ya yaz (alan adları [API tasarımından](../05-api-design.md)).
- Ertuğrul'un şeması için tablo ve alan listesini onayla.

### Hafta 5 (12 - 18 Eki): altın dilim
- `Report.assign(Actor)` (Rule 00, 05) ve testleri.
- `application`: `ReportRepository` arayüzü (`findById`, `tryAssign`), `AssignReport` servisi, `sealed class AppError`, `Result<T>`.
- `ListReports` servisi (görevli listesi; sayfalama parametreleri `PageRequest`).
- **Kabul testleri** (`bekliyor`): Ertuğrul için `tryAssign` yarış testi, Murat için `PUT /api/reports/{id}/assignment` HTTP testleri (`200`, `403`, `404`, `409`).
- Altın dilimi belgeleyen kısa bir yazı: "Yeni bir kullanım senaryosu nasıl eklenir" (`ekip/` altına, sonraki dilimler bunu kopyalar).

### Hafta 6 (19 - 25 Eki)
- `Report.resolve(Actor, Photo resolutionPhoto, String? note)` (Rule 03, 05; sonuç fotoğrafı zorunlu).
- `ResolveReport` servisi: durum, `StatusHistory` ve `Notification` tek çağrıda (`ReportRepository.resolve(...)`, işlemi Ertuğrul gerçekler; Rule 04).
- `Login` ve `Authenticate` servisleri; `UserRepository`, `SessionRepository`, `PasswordHasher` arayüzleri.
- Kabul testleri (`bekliyor`): çözme ve giriş için.

### Hafta 7 (26 Eki - 1 Kas)
- `CreateReport` servisi: kampüs sınırı (Rule 06), bina kaynağında bina koordinatı, fotoğraf kuralı (Rule 07); `PhotoStorage`, `BuildingRepository` arayüzleri.
- `ListMyReports`, `GetReport` (Rule 01: öğrenci yalnızca kendi bildirimi), `ListMyNotifications`, `MarkNotificationRead`, `ListBuildings`.
- Kabul testleri (`bekliyor`): bildirim açma, kampüs dışı, bina listesi.

### Hafta 8 (2 - 8 Kas)
- Yetki testleri: Rule 00, 01, 03 her endpoint için (sunucu katmanında, Murat'la birlikte).
- `app` içinde API istemcisinin ortak kısmı (`ApiClient`: token saklama, hata gövdesini okuma) ve sahte veriden gerçek API'ye geçiş anahtarı.
- Güvenlik gözden geçirmesi: [güvenlik dokümanındaki](../06-security-and-privacy.md) her satırın kodda karşılığı var mı.

### Hafta 9 (9 - 15 Kas): 1. sunum (varsayım)
- SonarQube Cloud kurulumu ve ilk tarama; sonuç [puan kaydına](../kayitlar/sonarqube-puanlari.md).
- Sunum: mimari, korumalar, altın dilim, canlı demo (giriş, aç, üstlen, çöz). 10 dakikayı geçmez.

### Hafta 10 (16 - 22 Kas)
- Sayfalama ve filtrelerin (`status`, `category`) servis ve testleri.
- Sonar bulgularının dağıtımı: her bulgu bir issue, sahibine atanır.

### Hafta 11 (23 - 29 Kas)
- Kalan "olmalı" işlerin servis tarafı; **dağıtım kararı** (VPS var mı) ve kapsam kesme kararı.
- ADR: kod mimarisi ve korumalar (ADR-03 taslağı).

### Hafta 12 (30 Kas - 6 Ara)
- **Pazar 6 Ara özellik dondurma.** Sonrası yalnızca hata düzeltme ve test.
- Kapsam ölçümü; `domain` ve `application` %90 hedefi.

### Hafta 13 (7 - 13 Ara)
- ADR'ları kesinleştir, README'yi koda göre güncelle (kurulum, çalıştırma, yapılandırma tablosu gerçek komutlarla).

### Hafta 14 (14 - 20 Ara): test haftası
- Test turunu yönet: herkesin bulduğu hata bir issue; öncelik sırası ve atama.
- Son kod incelemesi; `TODO`, kullanılmayan kod, sihirli sayı taraması.

### Hafta 15 (21 - 27 Ara): teslim
- Final README, sunum, katkı raporu; teslim dersinde 2. sunum.

## Raporlar

Çalıştığın **her gün** için bir rapor: `ekip/raporlar/huseyin-emre/YYYY-AA-GG.md`. Şablon: [günlük rapor şablonu](../Templates/gunluk-rapor.md). Rapor o günün iş branch'inde, işin PR'ıyla birlikte girer; PR açılmayan günün raporu bir sonraki PR'a eklenir. Yalnızca kendi klasörüne yaz. Dönem sonundaki katkı raporun bu raporlardan derlenir.

Yeni rapor ekleyince bu listeye bir satır ekle (en yeni üstte):

- [2026-10-02](raporlar/huseyin-emre/2026-10-02.md): ekip kuruldu, `main` koruması, planlar ve korumalar yazıldı
