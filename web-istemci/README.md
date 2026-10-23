# Campus Report: Web İstemcisi

Çekirdek Dart sunucusunun REST API'sini ([05-api-design](../proje-bilgileri/05-api-design.md)) tüketen ayrı web istemcisi. Karar: [ADR-04](../proje-bilgileri/adr/04-cok-dilli-web-ve-servisler.md). Issue: #90. Sahip: Murat Yaman.

- Saf HTML + CSS + JavaScript (ES modülleri). Framework, derleme adımı ve npm bağımlılığı yok.
- Testler Node'un yerleşik `node:test` modülüyle çalışır (Node 20+).

## Çalıştırma

ES modülleri `file://` üzerinden açılmaz; basit bir statik sunucu gerekir:

```bash
cd web-istemci
python3 -m http.server 5500
# Tarayıcı: http://localhost:5500
```

Sunucu adresi `js/yapilandirma.js` içindeki `API_TABAN_URL` sabitidir (varsayılan `http://localhost:8080`).

### Sahte veri modu (sunucu olmadan)

`GET /api/reports` sunucuda henüz yok (#20). Arayüzü denemek için:

```
http://localhost:5500/index.html?mock=1
```

Herhangi bir e-posta ve `demo` parolasıyla görevli olarak girilir (`ogrenci` ile başlayan e-posta öğrenci olarak girer). 46 uydurma bildirim gelir; filtre ve sayfalama sahte sunucuda da çalışır. Mod sekme kapanana kadar hatırlanır; kapatmak için `?mock=0`. Açıkken üst çubukta "Sahte veri" rozeti görünür.

## Test

```bash
cd web-istemci
npm test
```

## Yapı

| Dosya | Görev |
| --- | --- |
| `js/yapilandirma.js` | Sabitler: API adresi, sayfa boyutu, sayfa adları |
| `js/oturum.js` | Belirteç ve kullanıcıyı `sessionStorage`'da tutar |
| `js/api.js` | `fetch` sarmalayıcı: Bearer başlığı, 401 → tek yenileme → tekrar deneme, oturum düşerse girişe yönlendirme; hata biçimini ayrıştırır |
| `js/uygulama.js` | Tarayıcı bağlantıları: `sessionStorage`, `fetch`, yönlendirme |
| `index.html`, `js/giris-sayfasi.js` | Giriş ekranı (DOM) |
| `js/giris.js` | Giriş mantığı: form doğrulama, hata mesajı, rol bazlı yönlendirme |
| `raporlar.html`, `js/raporlar-sayfasi.js` | Bildirim listesi ekranı (DOM) |
| `js/raporlar.js` | Liste mantığı: boş liste ve hata mesajları, sayaç metni |
| `js/sorgu.js` | Filtre/sayfa ↔ adres çubuğu ↔ API sorgusu; sayfalama hesabı |
| `js/rapor.js` | Bildirim yanıtını elle okur (`fromJson` karşılığı); etiketler, tarih biçimi |
| `js/sahte-veri.js` | Sahte sunucu (`?mock=1`) |
| `css/stil.css` | Ortak stil; açık/koyu tema, dar ekran düzeni |
| `test/` | Birim testleri |

## Giriş davranışı

- `GET /api/reports` yalnızca görevliye açık olduğu için **görevli** listeye yönlendirilir; **öğrenci** uyarı görür ve oturumu kapatılır.
- Hatalı girişte hangi alanın yanlış olduğu söylenmez; parola alanı temizlenir.
- Zaten giriş yapmış görevli giriş sayfasını açarsa doğrudan listeye geçer.

## Liste davranışı

- Filtreler (durum, kategori, sayfa boyutu) ve sayfa numarası adres çubuğunda tutulur; sayfa yenilenince, geri/ileri tuşlarında ve paylaşılan bağlantıda korunur. Filtre değişince ilk sayfaya dönülür.
- Adresteki geçersiz değerler (bilinmeyen durum, `page=0`, `pageSize=500`) varsayılana veya sınıra çekilir; son sayfanın ötesi son sayfaya düzeltilir.
- Durumlar: yükleniyor (iskelet kartlar), boş liste (filtre varsa "filtreleri temizle"), hata (ağ hatasında "tekrar dene"), 403 (yalnızca görevli), 404 (liste uç noktası henüz yok → sahte modu öner).
- Hızlı filtre değişiminde eski isteğin geç gelen yanıtı yok sayılır.
- Kullanıcı verisi yalnızca `textContent` ile yazılır; açıklamadaki HTML çalışmaz.
- **Bina filtresi pasif:** `GET /api/reports` henüz `building` parametresi almıyor ([05-api-design](../proje-bilgileri/05-api-design.md#parametreler)).

## Varsayımlar (doğrulanmadı)

- `GET /api/reports` yanıtı `{ items, page, pageSize, total }` biçiminde olacak (bildirimler örneğiyle aynı), öğeler `ReportSummary` alanlarını taşıyacak. #20 tamamlanınca gerçek sunucuyla doğrulanmalı.
- `photoUrl` göreli yol (`/files/...`) olarak gelecek ve sunucu adresine eklenerek açılacak.

## Tasarım notları

- **İstisna yok:** API çağrıları `{ ok, veri }` veya `{ ok: false, hata: { durum, kod, mesaj, detay } }` döner (projenin `Result` yaklaşımıyla aynı).
- **Tek yenileme:** Aynı anda birden fazla istek 401 alırsa yalnızca bir `/api/auth/refresh` isteği yapılır; sunucu kullanılan yenileme belirtecini iptal ettiği için gerekli.
- **Sonsuz döngü yok:** Yenilemeden sonra yine 401 gelirse oturum silinir ve giriş ekranına dönülür.
