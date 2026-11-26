-- Sunum için demo verisi: 001_ornek.sql'in üstüne yüklenir (önce 001 çalışmalı).
-- Kişiler, e-postalar ve bildirimler uydurmadır; gerçek öğrenci verisi yoktur.
-- Bina koordinatları örnektir, gerçek kampüs sınırı değildir (Issue #4 bekleniyor).
-- Çalıştır: podman compose exec -T db psql -v ON_ERROR_STOP=1 -U campus -d campus < db/seed/002_demo.sql
-- Parola: Demo.1234 (001 ile aynı). Tarihler NOW()'a göre: sunum günü yüklenince taze görünür.
-- İki kez çalıştırmak güvenlidir (var olan satır atlanır). Fotoğraflar: db/seed/demo-fotolar/ (README).
-- Dağılım: 4 Yeni (görevlinin canlı üstlenmesi için), 3 Ustlenildi, 3 Cozuldu.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

BEGIN;

INSERT INTO buildings (building_id, name, latitude, longitude) VALUES
  ('b0000000-0000-4000-8000-000000000006', 'Mühendislik Fakültesi', 36.5890, 36.1729),
  ('b0000000-0000-4000-8000-000000000007', 'Rektörlük', 36.5868, 36.1725),
  ('b0000000-0000-4000-8000-000000000008', 'Öğrenci Yurdu', 36.5852, 36.1760),
  ('b0000000-0000-4000-8000-000000000009', 'Sağlık Merkezi', 36.5875, 36.1762),
  ('b0000000-0000-4000-8000-00000000000a', 'Otopark', 36.5848, 36.1733)
ON CONFLICT DO NOTHING;

-- Öğrenciler: 001'deki Ayşe ve Mehmet'e ek üç kişi. Görevli: Zeynep ve Ali'ye ek Hakan.
INSERT INTO users (user_id, full_name, email, password_hash, role)
SELECT id::uuid, full_name, email, crypt('Demo.1234', gen_salt('bf', 12)), role FROM (VALUES
  ('a0000000-0000-4000-8000-000000000005', 'Elif Şahin', 'elif@ornek.edu', 'Student'),
  ('a0000000-0000-4000-8000-000000000006', 'Burak Aydın', 'burak@ornek.edu', 'Student'),
  ('a0000000-0000-4000-8000-000000000007', 'Selin Koç', 'selin@ornek.edu', 'Student'),
  ('a0000000-0000-4000-8000-000000000009', 'Hakan Arslan', 'hakan@ornek.edu', 'Staff')
) AS u (id, full_name, email, role)
ON CONFLICT DO NOTHING;

-- Bina kaynaklı bildirimde konum binanın kayıtlı koordinatıdır (Rule 06).
INSERT INTO reports (
  report_id, reporter_id, assignee_id, category, description,
  photo_url, photo_content_type, photo_size_bytes,
  latitude, longitude, place, location_source, building_id,
  status, created_at, taken_at, resolved_at,
  resolution_photo_url, resolution_photo_content_type, resolution_photo_size_bytes,
  resolution_note
) VALUES
  -- Yeni
  ('c0000000-0000-4000-8000-000000000201', 'a0000000-0000-4000-8000-000000000005', NULL,
    'Ariza', 'Mühendislik Fakültesi 1. kat tuvaletinde lavabo musluğu su kaçırıyor',
    '/files/c0000000-0000-4000-8000-000000000201/a0000000000000000000000000000201.jpg', 'image/jpeg', 5066,
    36.5890, 36.1729, '1. kat tuvalet', 'Building', 'b0000000-0000-4000-8000-000000000006',
    'Yeni', NOW() - INTERVAL '3 hours', NULL, NULL, NULL, NULL, NULL, NULL),
  ('c0000000-0000-4000-8000-000000000202', 'a0000000-0000-4000-8000-000000000006', NULL,
    'Temizlik', 'Otopark girişindeki çöp kutusu taşmış, çevreye çöp saçılmış',
    '/files/c0000000-0000-4000-8000-000000000202/a0000000000000000000000000000202.jpg', 'image/jpeg', 4898,
    36.5849, 36.1734, 'Otopark girişi', 'Gps', NULL,
    'Yeni', NOW() - INTERVAL '5 hours', NULL, NULL, NULL, NULL, NULL, NULL),
  ('c0000000-0000-4000-8000-000000000203', 'a0000000-0000-4000-8000-000000000007', NULL,
    'Guvenlik', 'Yurt arkasındaki yürüyüş yolunda iki sokak lambası yanmıyor, akşam çok karanlık',
    '/files/c0000000-0000-4000-8000-000000000203/a0000000000000000000000000000203.jpg', 'image/jpeg', 4992,
    36.5850, 36.1763, 'Yurt arkası yürüyüş yolu', 'Gps', NULL,
    'Yeni', NOW() - INTERVAL '1 day 2 hours', NULL, NULL, NULL, NULL, NULL, NULL),
  ('c0000000-0000-4000-8000-000000000204', 'a0000000-0000-4000-8000-000000000001', NULL,
    'Diger', 'Rektörlük önündeki bankın oturma tahtası kırılmış',
    '/files/c0000000-0000-4000-8000-000000000204/a0000000000000000000000000000204.png', 'image/png', 5629,
    36.5868, 36.1725, 'Rektörlük önü', 'Building', 'b0000000-0000-4000-8000-000000000007',
    'Yeni', NOW() - INTERVAL '1 day 6 hours', NULL, NULL, NULL, NULL, NULL, NULL),
  -- Ustlenildi
  ('c0000000-0000-4000-8000-000000000206', 'a0000000-0000-4000-8000-000000000002',
    'a0000000-0000-4000-8000-000000000003',
    'Ariza', 'B Blok asansörü 3. katta takılı kalıyor, kapısı açılmıyor',
    '/files/c0000000-0000-4000-8000-000000000206/a0000000000000000000000000000206.jpg', 'image/jpeg', 5110,
    36.5871, 36.1742, 'Asansör, 3. kat', 'Building', 'b0000000-0000-4000-8000-000000000002',
    'Ustlenildi', NOW() - INTERVAL '2 days 4 hours', NOW() - INTERVAL '2 days 1 hour', NULL, NULL, NULL, NULL, NULL),
  ('c0000000-0000-4000-8000-000000000207', 'a0000000-0000-4000-8000-000000000005',
    'a0000000-0000-4000-8000-000000000009',
    'Temizlik', 'Yemekhane salonundaki masaların altında yemek artıkları birikmiş',
    '/files/c0000000-0000-4000-8000-000000000207/a0000000000000000000000000000207.jpg', 'image/jpeg', 4903,
    36.5860, 36.1748, 'Yemekhane salonu', 'Building', 'b0000000-0000-4000-8000-000000000004',
    'Ustlenildi', NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 days 20 hours', NULL, NULL, NULL, NULL, NULL),
  ('c0000000-0000-4000-8000-000000000208', 'a0000000-0000-4000-8000-000000000006',
    'a0000000-0000-4000-8000-000000000004',
    'Guvenlik', 'Spor salonu soyunma odasındaki dolapların kilitleri kırık',
    '/files/c0000000-0000-4000-8000-000000000208/a0000000000000000000000000000208.jpg', 'image/jpeg', 5104,
    36.5885, 36.1739, 'Spor salonu soyunma odası', 'Gps', NULL,
    'Ustlenildi', NOW() - INTERVAL '4 days', NOW() - INTERVAL '3 days 22 hours', NULL, NULL, NULL, NULL, NULL),
  -- Cozuldu: sonuç fotoğrafı zorunlu (Rule 04)
  ('c0000000-0000-4000-8000-000000000209', 'a0000000-0000-4000-8000-000000000007',
    'a0000000-0000-4000-8000-000000000004',
    'Ariza', 'Mühendislik Fakültesi amfi 3''teki projeksiyon cihazı açılmıyor',
    '/files/c0000000-0000-4000-8000-000000000209/a0000000000000000000000000000209.jpg', 'image/jpeg', 5101,
    36.5890, 36.1729, 'Amfi 3', 'Building', 'b0000000-0000-4000-8000-000000000006',
    'Cozuldu', NOW() - INTERVAL '6 days', NOW() - INTERVAL '5 days 23 hours',
    NOW() - INTERVAL '5 days 20 hours',
    '/files/c0000000-0000-4000-8000-000000000209/b0000000000000000000000000000209.jpg', 'image/jpeg', 5751,
    'Cihazın güç kablosu değiştirildi, çalışıyor.'),
  ('c0000000-0000-4000-8000-000000000210', 'a0000000-0000-4000-8000-000000000001',
    'a0000000-0000-4000-8000-000000000003',
    'Temizlik', 'A Blok giriş merdivenlerinde kırık cam parçaları var',
    '/files/c0000000-0000-4000-8000-000000000210/a0000000000000000000000000000210.jpg', 'image/jpeg', 4903,
    36.5865, 36.1735, 'Giriş merdivenleri', 'Building', 'b0000000-0000-4000-8000-000000000001',
    'Cozuldu', NOW() - INTERVAL '7 days', NOW() - INTERVAL '6 days 23 hours 30 minutes',
    NOW() - INTERVAL '6 days 22 hours',
    '/files/c0000000-0000-4000-8000-000000000210/b0000000000000000000000000000210.jpg', 'image/jpeg', 5734,
    'Cam parçaları toplandı, alan temizlendi.'),
  ('c0000000-0000-4000-8000-000000000212', 'a0000000-0000-4000-8000-000000000002',
    'a0000000-0000-4000-8000-000000000003',
    'Diger', 'Kampüs içindeki yön tabelası devrilmiş, yaya yolunu kapatıyor',
    '/files/c0000000-0000-4000-8000-000000000212/a0000000000000000000000000000212.jpg', 'image/jpeg', 4962,
    36.5866, 36.1728, 'Rektörlük yolu', 'Gps', NULL,
    'Cozuldu', NOW() - INTERVAL '12 days', NOW() - INTERVAL '11 days 23 hours',
    NOW() - INTERVAL '11 days 21 hours',
    '/files/c0000000-0000-4000-8000-000000000212/b0000000000000000000000000000212.jpg', 'image/jpeg', 5713,
    'Tabela yeniden sabitlendi.')
ON CONFLICT DO NOTHING;

-- Durum geçmişi bildirimlerden türetilir, uygulamanın yazdığı gibi:
-- oluşturma (boş -> Yeni, bildiren), üstlenme ve çözme (görevli).
-- Geçmişi olan bildirim atlanır; betik iki kez çalışırsa satır çoğalmaz.
INSERT INTO status_history (report_id, from_status, to_status, changed_by, changed_at, note)
SELECT r.report_id, s.from_status, s.to_status, s.changed_by, s.changed_at, s.note
FROM reports r
CROSS JOIN LATERAL (VALUES
  (NULL::varchar, 'Yeni', r.reporter_id, r.created_at, NULL::varchar),
  ('Yeni', 'Ustlenildi', r.assignee_id, r.taken_at, NULL),
  ('Ustlenildi', 'Cozuldu', r.assignee_id, r.resolved_at, r.resolution_note)
) AS s (from_status, to_status, changed_by, changed_at, note)
WHERE r.report_id::text LIKE 'c0000000-0000-4000-8000-0000000002%'
  AND s.changed_at IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM status_history h WHERE h.report_id = r.report_id);

-- Çözülen her bildirim için bildirene bir "çözüldü" haberi (Rule 04); mesaj
-- uygulamanınkiyle aynı. Selin'in haberi okunmuş, Ayşe'nin ve Mehmet'in değil.
INSERT INTO notifications (user_id, report_id, type, message, created_at, read_at)
SELECT reporter_id, report_id, 'ReportResolved', 'Bildiriminiz çözüldü.', resolved_at,
  CASE WHEN report_id = 'c0000000-0000-4000-8000-000000000209'
    THEN resolved_at + INTERVAL '2 hours' END
FROM reports
WHERE report_id::text LIKE 'c0000000-0000-4000-8000-0000000002%' AND status = 'Cozuldu'
ON CONFLICT (report_id, type) DO NOTHING;

COMMIT;
