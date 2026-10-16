-- V3: e-posta büyük/küçük harf fark etmeden tekil olsun.
-- V1'deki UNIQUE yalnızca birebir aynı yazımı engeller; "Ayse@ornek.edu" ile
-- "ayse@ornek.edu" iki ayrı hesap açabiliyordu. Giriş lower(email) ile aradığı için
-- iki satır eşleşir ve hangisinin seçileceği belirsiz kalırdı.
CREATE UNIQUE INDEX users_email_lower_key ON users (lower(email));
