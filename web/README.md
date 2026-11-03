# Web istemcisi (HTML/CSS/JS)

[ADR-04](../proje-bilgileri/adr/04-cok-dilli-web-ve-servisler.md) kararıyla açılan ayrı web istemcisi. Dart çekirdeğinin REST API'sini ([05-api-design](../proje-bilgileri/05-api-design.md)) tüketir. Sahibi: Murat Yaman (#90).

Bağımlılık, derleme adımı veya paket yöneticisi yok: düz HTML, CSS ve ES modülleri.

## Dosyalar

| Dosya | Ne yapar |
| --- | --- |
| `index.html`, `js/login-page.js` | Giriş ekranı; başarılı girişte `next` ile gelinen sayfaya döner |
| `reports.html`, `js/reports-page.js` | Bildirim listesi: durum, kategori, bina filtreleri ve sayfalama |
| `js/api.js` | API istemcisi; Bearer belirteci ekler, 401'de bir kez yeniler, olmazsa girişe yönlendirir |
| `js/token-store.js` | Belirteçleri `sessionStorage`'da tutar (sekme kapanınca oturum biter) |
| `js/reports.js` | Filtre okuma, kart, boş/hata durumu ve sayfalama çizimi |
| `js/session.js` | Sayfaların paylaştığı depo, istemci ve yönlendirme |
| `js/config.js` | Sunucu adresi, sayfa boyutu sabitleri |
| `tests/` | Tarayıcıda çalışan bağımlılıksız DOM ve API testleri |

## Çalıştırma

1. Veritabanını ve çekirdek sunucuyu ana [README](../README.md) adımlarıyla çalıştır; sunucu `http://localhost:8080` adresinde açılır.
2. `web/` klasörünü herhangi bir statik sunucuyla aç (ör. VS Code "Live Server" eklentisi veya `web/` içinde `python -m http.server 5500`). ES modülleri `file://` üzerinden yüklenmez.
3. Seed hesaplarıyla giriş yap (parolalar `db/seed/001_ornek.sql` başında). Liste yalnızca görevli rolüne açıktır.

Sunucu adresi `js/config.js` içindeki `API_BASE_URL` değeridir. Çekirdek CORS başlığı gönderdiği için web istemcisi farklı bir porttan açılabilir.

**Gerçek sunucuda denendi (3 Kasım 2026, yerel PostgreSQL 16.15 + seed):** görevli girişi, liste, durum ve kategori filtresi, boş sonuç, sayfalama, 401'de belirteç yenileme, iki belirteç de geçersizken girişe yönlendirme, yanlış parola ve öğrencinin `403` mesajı.

## Testler

Statik sunucu açıkken tarayıcıda `tests/index.html` sayfasını aç. Sonuç sayfada listelenir; `body` öğesinin `data-result` alanı `pass` ya da `fail` olur.

## Sunucuyla sözleşme

- `GET /api/reports` yanıtı `{ items, page, pageSize, total }`; her bildirimde konum düz `place` ve `buildingName` alanlarıyla gelir (`packages/server/lib/src/mapper/report_mapper.dart`). Kartta önce `place`, yoksa bina adı gösterilir.
- `GET /api/buildings` yanıtı `{ items: [{ buildingId, name, ... }] }`.
- Liste yalnızca görevli rolüne açıktır; öğrenci girerse `403` için "yalnızca görevliler" mesajı gösterilir.
- **Bina filtresi sunucuda yok:** istemci `buildingId` gönderir, ama çekirdek bu parametreyi henüz tanımadığı için bütün bildirimler gelir. Sunucu tarafı #160'ta.
