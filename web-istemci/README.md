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
| `test/` | Birim testleri |

## Tasarım notları

- **İstisna yok:** API çağrıları `{ ok, veri }` veya `{ ok: false, hata: { durum, kod, mesaj, detay } }` döner (projenin `Result` yaklaşımıyla aynı).
- **Tek yenileme:** Aynı anda birden fazla istek 401 alırsa yalnızca bir `/api/auth/refresh` isteği yapılır; sunucu kullanılan yenileme belirtecini iptal ettiği için gerekli.
- **Sonsuz döngü yok:** Yenilemeden sonra yine 401 gelirse oturum silinir ve giriş ekranına dönülür.
