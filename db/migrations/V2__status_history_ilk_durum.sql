-- V2: bildirimin oluşması (NULL -> Yeni) da durum geçmişine yazılabilsin.
-- from_status yalnızca ilk kayıtta boştur; doluysa CHECK yine üç durumdan birini ister.
ALTER TABLE status_history ALTER COLUMN from_status DROP NOT NULL;
