-- V1: ilk şema. Alanlar proje-bilgileri/03-domain-design.md ile aynıdır.
-- gen_random_uuid() PostgreSQL 13+ ile yerleşiktir, eklenti gerekmez.

CREATE TABLE users (
  user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name VARCHAR(100) NOT NULL CHECK (char_length(full_name) BETWEEN 3 AND 100),
  email VARCHAR(254) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(10) NOT NULL CHECK (role IN ('Student', 'Staff')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Giriş oturumları: refresh token yalnızca hash olarak saklanır (Issue #19).
CREATE TABLE sessions (
  session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(user_id),
  refresh_token_hash VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  revoked_at TIMESTAMPTZ,
  CHECK (expires_at > created_at)
);

CREATE INDEX idx_sessions_user ON sessions(user_id);

CREATE TABLE buildings (
  building_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL UNIQUE CHECK (char_length(name) BETWEEN 2 AND 100),
  latitude DOUBLE PRECISION NOT NULL CHECK (latitude BETWEEN -90 AND 90),
  longitude DOUBLE PRECISION NOT NULL CHECK (longitude BETWEEN -180 AND 180)
);

CREATE TABLE reports (
  report_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES users(user_id),
  assignee_id UUID REFERENCES users(user_id),
  category VARCHAR(20) NOT NULL CHECK (category IN ('Ariza', 'Temizlik', 'Guvenlik', 'Diger')),
  description VARCHAR(500) NOT NULL CHECK (char_length(description) BETWEEN 5 AND 500),
  photo_url VARCHAR(500) NOT NULL,
  photo_content_type VARCHAR(50) NOT NULL CHECK (photo_content_type IN ('image/jpeg', 'image/png')),
  photo_size_bytes BIGINT NOT NULL CHECK (photo_size_bytes > 0),
  latitude DOUBLE PRECISION NOT NULL CHECK (latitude BETWEEN -90 AND 90),
  longitude DOUBLE PRECISION NOT NULL CHECK (longitude BETWEEN -180 AND 180),
  place VARCHAR(100),
  location_source VARCHAR(10) NOT NULL CHECK (location_source IN ('Gps', 'Building')),
  building_id UUID REFERENCES buildings(building_id),
  status VARCHAR(20) NOT NULL DEFAULT 'Yeni' CHECK (status IN ('Yeni', 'Ustlenildi', 'Cozuldu')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  taken_at TIMESTAMPTZ,
  resolved_at TIMESTAMPTZ,
  resolution_photo_url VARCHAR(500),
  resolution_photo_content_type VARCHAR(50)
    CHECK (resolution_photo_content_type IN ('image/jpeg', 'image/png')),
  resolution_photo_size_bytes BIGINT CHECK (resolution_photo_size_bytes > 0),
  resolution_note VARCHAR(500),
  -- Rule 06: bina kaynağında bina zorunlu.
  CHECK (location_source <> 'Building' OR building_id IS NOT NULL),
  -- Durumla uyumlu alanlar: Yeni iken görevli yok, Ustlenildi iken var.
  CHECK (status <> 'Yeni' OR (assignee_id IS NULL AND taken_at IS NULL)),
  CHECK (status = 'Yeni' OR (assignee_id IS NOT NULL AND taken_at IS NOT NULL)),
  -- Rule 04: Cozuldu iken sonuç fotoğrafı zorunlu, diğer durumlarda boş.
  CHECK (
    (status = 'Cozuldu') = (resolved_at IS NOT NULL AND resolution_photo_url IS NOT NULL
      AND resolution_photo_content_type IS NOT NULL AND resolution_photo_size_bytes IS NOT NULL)
  )
);

CREATE INDEX idx_reports_status_created ON reports(status, created_at DESC);
CREATE INDEX idx_reports_assignee ON reports(assignee_id) WHERE assignee_id IS NOT NULL;
CREATE INDEX idx_reports_reporter ON reports(reporter_id);

CREATE TABLE status_history (
  status_history_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_id UUID NOT NULL REFERENCES reports(report_id),
  from_status VARCHAR(20) NOT NULL CHECK (from_status IN ('Yeni', 'Ustlenildi', 'Cozuldu')),
  to_status VARCHAR(20) NOT NULL CHECK (to_status IN ('Yeni', 'Ustlenildi', 'Cozuldu')),
  changed_by UUID NOT NULL REFERENCES users(user_id),
  changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  note VARCHAR(500)
);

CREATE INDEX idx_status_history_report ON status_history(report_id, changed_at);

CREATE TABLE notifications (
  notification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(user_id),
  report_id UUID NOT NULL REFERENCES reports(report_id),
  type VARCHAR(20) NOT NULL CHECK (type IN ('ReportResolved')),
  message VARCHAR(200) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  read_at TIMESTAMPTZ,
  -- Rule 04: öğrenciye bir kez "çözüldü" bildirimi.
  UNIQUE (report_id, type)
);

CREATE INDEX idx_notifications_user_read ON notifications(user_id, read_at);
