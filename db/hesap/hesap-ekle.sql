-- Canlı ortamda hesap açar (kayıt ekranı yok; demo seed'i canlıya yüklenmez).
-- Parola komut satırına yazılmaz: PAROLA ortam değişkeninden okunur (\getenv),
-- böylece kabuk geçmişinde ve süreç listesinde görünmez. Kullanım: README "Canlı ortam".
-- Değişkenler: ad, eposta, rol (Student ya da Staff); PAROLA ortamdan.
-- Bir denetim geçmezse hata verilir (çıkış kodu 3) ve hesap açılmaz.
\set ON_ERROR_STOP on
\getenv parola PAROLA

\if :{?parola}
\else
  DO $$ BEGIN RAISE EXCEPTION 'PAROLA ortam degiskeni verilmedi; hesap acilmadi'; END $$;
\endif

-- Seed'deki gibi kısa ve herkesin bildiği parolalar canlıda kullanılmasın.
SELECT char_length(:'parola') >= 10 AS parola_yeterli,
       :'rol' IN ('Student', 'Staff') AS rol_gecerli \gset
\if :parola_yeterli
\else
  DO $$ BEGIN RAISE EXCEPTION 'Parola en az 10 karakter olmali; hesap acilmadi'; END $$;
\endif
-- Rol önceden denetlenir: CHECK hatası satırı (parola özetiyle) ekrana ve günlüğe basardı.
\if :rol_gecerli
\else
  DO $$ BEGIN RAISE EXCEPTION 'rol Student ya da Staff olmali; hesap acilmadi'; END $$;
\endif

-- bcrypt (cost 12): seed ve sunucunun parola doğrulamasıyla aynı biçim.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

INSERT INTO users (full_name, email, password_hash, role)
VALUES (:'ad', lower(trim(:'eposta')), crypt(:'parola', gen_salt('bf', 12)), :'rol')
RETURNING user_id, email, role;
