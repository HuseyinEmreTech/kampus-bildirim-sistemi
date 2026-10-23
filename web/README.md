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

ES modülleri `file://` üzerinden yüklenmez; klasörü herhangi bir statik sunucuyla aç (ör. VS Code "Live Server" eklentisi veya `python -m http.server 5500` komutu `web/` içinde). Sunucu adresi `js/config.js` içindeki `API_BASE_URL` değeridir (varsayılan `http://localhost:8080`).

Web istemcisi çekirdekten farklı bir adresten (port) açıldığında tarayıcı CORS kuralı uygular. Çekirdekte şu an CORS başlığı yok; bu yüzden gerçek sunucuya bağlanmak için çekirdeğe CORS ara katmanı eklenmeli (sunucu sahibine iş, bu PR kapsamı dışında). **Doğrulanmadı.**

## Testler

Statik sunucu açıkken tarayıcıda `tests/index.html` sayfasını aç. Sonuç sayfada listelenir; `body` öğesinin `data-result` alanı `pass` ya da `fail` olur.

## Varsayımlar

- `GET /api/reports` yanıtı `{ items, page, pageSize, total }` biçimindedir (bildirimlerim örneğiyle aynı). Endpoint çekirdekte henüz yok.
- Bina filtresi için `buildingId` sorgu parametresi gönderilir; API dokümanında **öneri** olarak eklendi.
- `GET /api/buildings` yanıtı `[{ buildingId, name }]` ya da `{ items: [...] }` olabilir; ikisi de kabul edilir.
- Liste yalnızca görevli rolüne açıktır; öğrenci girerse `403` için "yalnızca görevliler" mesajı gösterilir.
