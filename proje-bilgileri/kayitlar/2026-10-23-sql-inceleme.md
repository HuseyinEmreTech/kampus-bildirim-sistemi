---
title: 23 Ekim 2026 - SQL İncelemesi (Migration ve Sorgular)
durum: Güncel
son-guncelleme: 2026-11-01
---

# 23 Ekim 2026 - SQL İncelemesi (Migration ve Sorgular)

← [İndeks](../00-index.md)

İnceleyen: Murat Yaman ([kişisel plan](../ekip/yamanmurat.md): "migration ve sorguları gözden geçir; yavaş sorgu notu çıkar"). Yalnızca inceleme; migration veya kod değişmedi.

## Kapsam ve yöntem

- **Okunan:** `db/migrations/V1`-`V4`, `db/prod/ilk-kurulum.sh`, `packages/infrastructure/lib/src/repository/*.dart` içindeki bütün SQL.
- **Ölçüm ortamı:** yerel PostgreSQL 16.15 (geçici, ölçümden sonra silindi), V1-V4 uygulanmış. Sahte veri: 500 öğrenci, 20 görevli, 10 bina, **50.000 bildirim** (%20 `Yeni`, %20 `Ustlenildi`, %60 `Cozuldu`), 50.000 durum geçmişi, 30.000 bildirim kutusu satırı. Ölçek V4'teki ölçümle aynı seçildi; gerçek kullanım bunun çok altında.
- **Ölçüm:** `EXPLAIN ANALYZE`, her sorgu üç kez çalıştırılıp sonuncusu alındı (önbellek ısınmış). Tek makinede ölçüldü; mutlak süreler makineye göre değişir, karşılaştırma için anlamlı.
- **İki plan türü:** sorgular hem `plan_cache_mode = force_custom_plan` (parametre değeriyle planlanır) hem `force_generic_plan` (değerden bağımsız tek plan) ile ölçüldü. Neden önemli olduğu aşağıda (Bulgu 1).

## Sonuç özeti

**Bugünkü kullanımda yavaş sorgu yok.** Bütün liste, sayım, geçmiş ve bildirim sorguları 50.000 bildirimde ilk sayfada 1 ms'nin altında; en yavaşı süzgeçsiz sayım (~7 ms). Şema kuralları (CHECK) domain kurallarıyla tutarlı, SQL'in tamamı parametreli.

İki **gizli risk** ve iki **küçük iyileştirme** önerisi var; hiçbiri şu an acil değil. Ölçümler 23 Ekim'e aittir; 1 Kasım'da `main` ile yapılan karşılaştırma [aşağıda](#güncel-kodla-karşılaştırma-1-kasım-2026).

## Ölçümler

Özel plan (bugünkü durum, aşağıda neden):

| Sorgu | Süre | Plan |
| --- | --- | --- |
| Liste, süzgeçsiz, 1. sayfa | 0,09 ms | `idx_reports_created` (V4) |
| Liste, `status=Yeni`, 1. sayfa | 0,09 ms | `idx_reports_status_created` + artımlı sıralama |
| Liste, `category=Ariza`, 1. sayfa | 0,13 ms | `idx_reports_created` |
| Liste, `status` + `category`, 1. sayfa | 0,10 ms | `idx_reports_status_created` + artımlı sıralama |
| Liste, `assignee=me`, 1. sayfa | 0,27 ms | `idx_reports_created` |
| Liste, öğrencinin kendi bildirimleri | 0,12 ms | `idx_reports_reporter` + sıralama |
| Liste, süzgeçsiz, 100. sayfa (OFFSET 1.980) | 2,1 ms | `idx_reports_created` |
| Liste, süzgeçsiz, son sayfa (OFFSET 49.980) | 61 ms | `idx_reports_created`, 50.000 satır atlanıyor |
| Sayım, süzgeçsiz | 6,8 ms | tam tablo taraması |
| Sayım, `status=Yeni` | 1,9 ms | `idx_reports_status_created` |
| Sayım, öğrencinin kendi bildirimleri | 0,04 ms | `idx_reports_reporter` |
| Bildirim kutusu, 1. sayfa | 0,02 ms | `idx_notifications_user_read` + sıralama |
| Okunmamış sayısı | 0,02 ms | `idx_notifications_user_read` |
| Durum geçmişi | 0,02 ms | `idx_status_history_report` |

Aynı liste sorguları **genel planla**:

| Sorgu | Özel plan | Genel plan |
| --- | --- | --- |
| Liste, süzgeçsiz, 1. sayfa | 0,09 ms | **80 ms** (tam tarama + 50.000 satır sıralama) |
| Liste, `status=Yeni` | 0,09 ms | 21 ms |
| Liste, `category=Ariza` | 0,13 ms | 25 ms |
| Liste, `assignee=me` | 0,27 ms | 12 ms |
| Liste, öğrencinin kendi bildirimleri | 0,12 ms | 9 ms |
| Sayım, `status=Yeni` | 1,9 ms | 15 ms |

Bildirim kutusu ve durum geçmişi sorgularında iki plan arasında fark yok (süzgeç koşulu sabit).

## Bulgular

### 1. `$1 IS NULL OR ...` kalıbı genel planda indeksi kullanamıyor (gizli risk)

`ReportRepositoryImpl._listSql` ve `_countSql`, boş süzgeci `($1::text IS NULL OR r.status = $1::text)` ile devre dışı bırakıyor. Bu, SQL'i sabit tutup metin birleştirmeyi önlüyor (AGENTS.md kuralı) ve **özel planda** sorunsuz: PostgreSQL parametre değerini bildiği için boş koşulu atıp doğru indeksi seçiyor.

**Genel planda** ise değer bilinmediğinden hiçbir koşul atılamıyor; planlayıcı tam tarama + sıralama seçiyor ve ilk sayfa 900 kat yavaşlıyor (0,09 → 80 ms).

**Bugün neden sorun değil (doğrulandı):** `postgres` paketi 3.5.20'de `Pool.execute(sql, parameters: ...)` her çağrıda **adsız ifade** (unnamed statement) kullanıyor; ayrıştırma, bağlama ve çalıştırma tek seferde gidiyor (paket kaynağı `lib/src/v3/connection.dart`). Adsız ifade her seferinde yeniden ayrıştırıldığı için PostgreSQL her çalıştırmada özel plan yapıyor.

**Ne zaman sorun olur:**

- Biri performans için `pool.prepare(...)` ile **adlı hazır ifadeye** geçerse: PostgreSQL beş çalıştırmadan sonra genel plana geçebilir (`plan_cache_mode = auto`).
- Veritabanı ayarında `plan_cache_mode = force_generic_plan` açılırsa.

**Öneri:** Şimdilik değişiklik gerekmez. `ReportRepositoryImpl._listSql` üstündeki yoruma "adlı hazır ifadeye (`prepare`) geçilmemeli; geçilirse süzgeç kalıbı genel planda indeks kullanamaz (bkz. bu kayıt)" notu eklenebilir. Bu dosya Ertuğrul'un alanında; karar onun.

### 2. Derin sayfalarda OFFSET maliyeti (gizli risk, ölçekte değil)

`LIMIT/OFFSET` atlanan satırları da okur: 100. sayfa 2 ms, 50.000 bildirimin son sayfası 61 ms. Ders projesi ölçeğinde (birkaç yüz kullanıcı, birkaç bin bildirim) bu sorun olmaz ve 05-api-design `page`/`pageSize` istediği için OFFSET doğru seçim.

**Öneri:** Değişiklik yok. Ölçek büyürse anahtar tabanlı (keyset) sayfalama: `WHERE (created_at, report_id) < ($son_tarih, $son_id)`. Mevcut `idx_reports_created (created_at DESC, report_id DESC)` buna zaten uygun.

### 3. Bina filtresi eklenirse indeks gerekir (iyileştirme)

Bina filtresi #160 ile ekleniyor; API'de henüz yok. Ölçüm (`building_id` ile süzme, bir binada ~1.700 bildirim):

| | İndekssiz | `(building_id, created_at DESC, report_id DESC)` indeksiyle |
| --- | --- | --- |
| Liste, 1. sayfa | 0,5 ms | 0,04 ms |
| Sayım | 6,6 ms | 0,5 ms |

`reports.building_id` yabancı anahtar olduğu hâlde indeksi yok. Bina filtresi eklenirken yeni bir migration (V5) ile bu indeks önerilir; liste sorgusuna da diğerleriyle aynı kalıpta `($5::uuid IS NULL OR r.building_id = $5::uuid)` eklenir. #160'ın sahibi Ertuğrul; kabul ölçütünde indeks yok, karar onun.

### 4. Durum geçmişinde eşit zaman sırası (küçük)

`_historySql` yalnızca `ORDER BY h.changed_at` ile sıralıyor. İki satırın zamanı birebir aynı olursa sıra belirsiz kalır. Her durum değişikliği ayrı işlemde yazıldığı için (`NOW()` işlem başlangıcı) pratikte olası değil.

**Öneri:** İsteğe bağlı olarak `ORDER BY h.changed_at, h.status_history_id` eklenebilir; liste sorgularındaki ikinci sıralama ölçütü alışkanlığıyla tutarlı olur.

## Gözlemler (bulgu değil)

- **Fazladan e-posta indeksi:** V1'deki `email UNIQUE` kısıtı ve V3'teki `lower(email)` tekil indeksi birlikte duruyor. Giriş yalnızca `lower(email)` ile arıyor; V1 indeksi yazmada küçük bir maliyet. Kaldırmak migration gerektirir; ölçekte önemsiz, dokunulmamalı.
- **`idx_sessions_user`:** 23 Ekim'de hiçbir sorguda kullanılmıyordu. #136 ile gelen `_revokeAllAfterReuseSql` artık `user_id` ile arıyor; indeks kalmalı. Planın gerçekten bu indeksi seçtiği ölçülmedi.
- **Süresi dolan oturumlar silinmiyor:** `sessions` tablosu her girişte ve yenilemede büyüyor. Ölçekte önemsiz; istenirse ileride `expires_at < NOW() - interval '30 days'` temizliği.
- **Migration takibi yok:** `ilk-kurulum.sh` V*.sql dosyalarını yalnızca ilk kurulumda uyguluyor; sonrakiler elle. Hangi migration'ın uygulandığını tutan bir tablo yok. Ders projesi için yeterli; canlı ortamda yeni migration eklenirken dikkat.
- **Olumlu:** Bütün SQL parametreli; durum kuralları (Rule 02, 03, 04, 06) hem `UPDATE ... WHERE` koşulunda hem CHECK kısıtlarında; üstlenme yarışı tek `UPDATE` ile çözülmüş; sunucunun veritabanı kullanıcısı tablo silemiyor (`ilk-kurulum.sh`).

## Güncel kodla karşılaştırma (1 Kasım 2026)

23 Ekim'den sonra `main`'e giren kod okunarak karşılaştırıldı. Bu makinede PostgreSQL yok; **ölçümler yenilenmedi**, yukarıdaki sayılar 23 Ekim'e aittir.

| Konu | 1 Kasım durumu |
| --- | --- |
| Bulgu 1 | Geçerli. `report_repository_impl.dart` aynı kalıbı kullanıyor, `prepare` çağrısı yok, `postgres` paketi hâlâ 3.5.20 |
| Bulgu 2 | Geçerli. Listeler `LIMIT/OFFSET` kullanıyor |
| Bulgu 3 | Geçerli. Migration'lar hâlâ V1-V4, `building_id` indeksi yok; filtre #160'ta |
| Bulgu 4 | Geçerli. `_historySql` hâlâ yalnızca `ORDER BY h.changed_at` |
| Yeni kalıp | #139 `notification_repository_impl.dart` içinde `(NOT $4::boolean OR n.read_at IS NULL)` ekledi. Bulgu 1'deki kalıba benziyor; 23 Ekim ölçümlerinde yok, genel plan davranışı **ölçülmedi** |

## Eyleme dönük bulgular

| Bulgu | Önerilen iş | Sahip |
| --- | --- | --- |
| 1 | `_listSql` üstüne "`prepare` kullanılmamalı" yorumu | Ertuğrul |
| 3 | #160 ile birlikte V5 migration: `(building_id, created_at DESC, report_id DESC)` indeksi | Ertuğrul |
| 4 | `_historySql` için ikinci sıralama ölçütü `h.status_history_id` | Ertuğrul |

Bulgu 2 ve gözlemler için iş açılmaz: ölçekte gerekli değil.

## Doğrulanmayanlar

- Ölçümler gerçek sunucu üzerinden değil, doğrudan `psql` ile yapıldı; ağ ve sürücü süresi dahil değil.
- `tr-x-icu` sıralaması (bina listesi) ölçüm ortamında denenmedi.
- Canlı ortamın (`compose.prod.yaml`) PostgreSQL ayarları incelenmedi.
