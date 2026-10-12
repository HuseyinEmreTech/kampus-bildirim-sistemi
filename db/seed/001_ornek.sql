-- Sahte örnek veri (seed): yalnızca yerel geliştirme ve demo içindir.
-- Kişiler, e-postalar ve bildirimler uydurmadır; gerçek öğrenci verisi yoktur.
-- Bina koordinatları örnektir, gerçek kampüs sınırı değildir (Issue #4 bekleniyor).
-- Çalıştır: podman compose exec -T db psql -U campus -d campus < db/seed/001_ornek.sql
--
-- Tüm sahte hesapların parolası: Demo.1234 (yalnızca demo; gerçek hesapta kullanma)
-- Parola düz metin saklanmaz; pgcrypto ile bcrypt (cost 12) hash'i yazılır.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

BEGIN;

INSERT INTO buildings (building_id, name, latitude, longitude) VALUES
  ('b0000000-0000-4000-8000-000000000001', 'A Blok', 36.5865, 36.1735),
  ('b0000000-0000-4000-8000-000000000002', 'B Blok', 36.5871, 36.1742),
  ('b0000000-0000-4000-8000-000000000003', 'Kütüphane', 36.5878, 36.1750),
  ('b0000000-0000-4000-8000-000000000004', 'Yemekhane', 36.5860, 36.1748),
  ('b0000000-0000-4000-8000-000000000005', 'Spor Salonu', 36.5884, 36.1738);

INSERT INTO users (user_id, full_name, email, password_hash, role) VALUES
  ('a0000000-0000-4000-8000-000000000001', 'Ayşe Yılmaz', 'ayse@ornek.edu',
    crypt('Demo.1234', gen_salt('bf', 12)), 'Student'),
  ('a0000000-0000-4000-8000-000000000002', 'Mehmet Kaya', 'mehmet@ornek.edu',
    crypt('Demo.1234', gen_salt('bf', 12)), 'Student'),
  ('a0000000-0000-4000-8000-000000000003', 'Zeynep Demir', 'zeynep@ornek.edu',
    crypt('Demo.1234', gen_salt('bf', 12)), 'Staff'),
  ('a0000000-0000-4000-8000-000000000004', 'Ali Çelik', 'ali@ornek.edu',
    crypt('Demo.1234', gen_salt('bf', 12)), 'Staff');

-- Üç bildirim, her durumdan bir tane: Yeni, Ustlenildi, Cozuldu.
INSERT INTO reports (
  report_id, reporter_id, assignee_id, category, description,
  photo_url, photo_content_type, photo_size_bytes,
  latitude, longitude, place, location_source, building_id,
  status, created_at, taken_at, resolved_at,
  resolution_photo_url, resolution_photo_content_type, resolution_photo_size_bytes,
  resolution_note
) VALUES
  ('c0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', NULL,
    'Ariza', 'B blok 2. kat koridor lambası yanmıyor',
    '/files/c0000000-0000-4000-8000-000000000001/foto.jpg', 'image/jpeg', 812345,
    36.5871, 36.1742, 'B Blok 2. kat', 'Gps', NULL,
    'Yeni', '2026-10-12 09:15:00+03', NULL, NULL,
    NULL, NULL, NULL, NULL),
  ('c0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000002',
    'a0000000-0000-4000-8000-000000000003',
    'Temizlik', 'Yemekhane girişinde dökülmüş içecek var',
    '/files/c0000000-0000-4000-8000-000000000002/foto.jpg', 'image/jpeg', 640210,
    36.5860, 36.1748, 'Yemekhane girişi', 'Building', 'b0000000-0000-4000-8000-000000000004',
    'Ustlenildi', '2026-10-12 10:00:00+03', '2026-10-12 10:20:00+03', NULL,
    NULL, NULL, NULL, NULL),
  ('c0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000001',
    'a0000000-0000-4000-8000-000000000004',
    'Guvenlik', 'Kütüphane arka kapısının kilidi kırık',
    '/files/c0000000-0000-4000-8000-000000000003/foto.png', 'image/png', 1048576,
    36.5878, 36.1750, 'Kütüphane arka kapı', 'Gps', NULL,
    'Cozuldu', '2026-10-11 14:00:00+03', '2026-10-11 14:30:00+03', '2026-10-11 16:00:00+03',
    '/files/c0000000-0000-4000-8000-000000000003/sonuc.jpg', 'image/jpeg', 700000,
    'Kilit değiştirildi.');

-- Durum geçmişi: her geçiş bir satır.
INSERT INTO status_history (report_id, from_status, to_status, changed_by, changed_at, note) VALUES
  ('c0000000-0000-4000-8000-000000000002', 'Yeni', 'Ustlenildi',
    'a0000000-0000-4000-8000-000000000003', '2026-10-12 10:20:00+03', NULL),
  ('c0000000-0000-4000-8000-000000000003', 'Yeni', 'Ustlenildi',
    'a0000000-0000-4000-8000-000000000004', '2026-10-11 14:30:00+03', NULL),
  ('c0000000-0000-4000-8000-000000000003', 'Ustlenildi', 'Cozuldu',
    'a0000000-0000-4000-8000-000000000004', '2026-10-11 16:00:00+03', 'Kilit değiştirildi.');

-- Çözülen bildirim için öğrenciye "çözüldü" haberi (okunmamış).
INSERT INTO notifications (user_id, report_id, type, message, created_at) VALUES
  ('a0000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000003',
    'ReportResolved', 'Bildiriminiz çözüldü: Kütüphane arka kapısının kilidi kırık',
    '2026-10-11 16:00:00+03');

COMMIT;
