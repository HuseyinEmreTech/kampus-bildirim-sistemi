-- V5: dokümandaki kuralların V1'de eksik kalan veritabanı kısıtları (Hafta 8).
-- Kurallar asıl olarak domain ve servislerde denetlenir; bu kısıtlar bir kod hatası
-- kuralı atlasa bile bozuk satırın kaydedilmesini engeller. Kısıt eklenirken mevcut
-- satırlar da denetlenir; uymayan satır varsa migration hata verir ve hiçbir şey değişmez.

BEGIN;

-- Rule 07: fotoğraf en fazla 5 MB (5 * 1024 * 1024 bayt). V1 yalnızca > 0 diyordu.
ALTER TABLE reports
  ADD CONSTRAINT reports_photo_size_max CHECK (photo_size_bytes <= 5242880),
  ADD CONSTRAINT reports_resolution_photo_size_max
    CHECK (resolution_photo_size_bytes <= 5242880);

-- Zamanlar sırayla ilerler: oluşma <= üstlenme <= çözülme. Aynı işlemde (transaction)
-- yazılan zamanlar eşit olabilir. Alan boşken CHECK sonucu NULL olur, kısıt geçer.
ALTER TABLE reports
  ADD CONSTRAINT reports_taken_after_created CHECK (taken_at >= created_at),
  ADD CONSTRAINT reports_resolved_after_taken CHECK (resolved_at >= taken_at);

-- Rule 05: durum geçmişine yalnızca diyagramdaki geçişler yazılır
-- (oluşma -> Yeni -> Ustlenildi -> Cozuldu). V1'deki CHECK'ler her durumu tek tek
-- kabul ediyordu; "Yeni -> Cozuldu" gibi bir atlama kaydedilebiliyordu.
-- COALESCE: from_status boşken karşılaştırma NULL olur ve CHECK NULL'ı geçer sayar;
-- "boş -> Ustlenildi" kaçmasın diye boş değer hiçbir duruma eşit olmayan '' yapılır.
ALTER TABLE status_history
  ADD CONSTRAINT status_history_valid_transition CHECK (
    (COALESCE(from_status, ''), to_status) IN (
      ('', 'Yeni'), ('Yeni', 'Ustlenildi'), ('Ustlenildi', 'Cozuldu')
    )
  );

-- E-postada tam olarak bir @ ve iki yanında boşluksuz metin. Ayrıntılı biçim denetimi
-- domain'dedir (03-domain-design, User); bu yalnızca açıkça bozuk değeri durdurur.
ALTER TABLE users
  ADD CONSTRAINT users_email_format CHECK (email ~ '^[^@[:space:]]+@[^@[:space:]]+$');

COMMIT;
