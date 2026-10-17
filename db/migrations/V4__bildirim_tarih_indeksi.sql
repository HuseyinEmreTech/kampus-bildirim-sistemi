-- V4: süzgeçsiz ya da yalnızca kategoriye göre bildirim listesi için indeks.
-- Liste yeniden eskiye sıralanır (created_at DESC, report_id DESC). V1'deki indeksler
-- durum, görevli ve bildirene göre süzülen listeyi karşılıyor; süzgeç yoksa PostgreSQL
-- bütün tabloyu okuyup sıralıyordu. Bu indeksle ilk sayfa doğrudan okunur.
-- Ölçüm (50.000 bildirim, EXPLAIN ANALYZE): süzgeçsiz liste 51 ms -> 0,2 ms,
-- kategori süzgeci 18 ms -> 0,2 ms.
CREATE INDEX idx_reports_created ON reports (created_at DESC, report_id DESC);
