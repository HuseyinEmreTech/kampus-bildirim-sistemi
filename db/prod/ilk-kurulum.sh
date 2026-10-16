#!/bin/sh
# Canlı ortamın ilk kurulumu (compose.prod.yaml). PostgreSQL bunu yalnızca veri
# klasörü boşken, ilk açılışta bir kez çalıştırır.
#
# 1. db/migrations içindeki V*.sql dosyalarını sürüm sırasıyla uygular
#    (V10, V2'den sonra gelir).
# 2. Sunucu için kısıtlı bir kullanıcı açar: yalnızca tablolardaki veriyi okur ve
#    yazar; tablo silemez, değiştiremez, yeni tablo açamaz. Böylece sunucudaki bir
#    hata ya da sızan şifre şemayı bozamaz.
#
# Not: dosya Windows'ta çalıştırılabilir izni olmadan gelirse PostgreSQL onu
# kendi kabuğunda "source" eder; bu yüzden "set -u" kullanılmaz (onun kabuğuna da
# geçerdi).
set -e

: "${APP_DB_USER:?APP_DB_USER .env dosyasinda tanimli olmali}"
: "${APP_DB_PASSWORD:?APP_DB_PASSWORD .env dosyasinda tanimli olmali}"

for migration in $(ls /migrations/V*__*.sql | sort -V); do
  echo "ilk-kurulum: $migration"
  psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f "$migration"
done

# Ad ve şifre psql değişkeniyle verilir (:"ad", :'sifre'); SQL metnine eklenmez.
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -v app_user="$APP_DB_USER" -v app_password="$APP_DB_PASSWORD" \
  -v db_name="$POSTGRES_DB" <<'SQL'
CREATE ROLE :"app_user" LOGIN PASSWORD :'app_password';
GRANT CONNECT ON DATABASE :"db_name" TO :"app_user";
GRANT USAGE ON SCHEMA public TO :"app_user";
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO :"app_user";
-- Sonradan elle uygulanan migration'ların tabloları da aynı izni alsın.
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO :"app_user";
SQL
echo "ilk-kurulum: $APP_DB_USER kullanıcısı açıldı"
