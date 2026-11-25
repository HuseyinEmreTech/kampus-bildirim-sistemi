---
title: Mimari Genel Bakış
durum: Güncel
son-guncelleme: 2026-11-26
---

# Mimari Genel Bakış

← [İndeks](00-index.md)

> Teknoloji seçimleri öneridir; hoca görüşü ve takım/süre netleşince kesinleşir. Gerekçe: [ADR-01](adr/01-dart-backend-postgresql.md).

## Teknoloji tablosu

| Konu | Teknoloji | Açıklama |
| --- | --- | --- |
| İstemci | Flutter (Dart) | En fazla 6-7 ekran; mobil ve web |
| Backend | Dart, Shelf | Küçük ve anlaşılır çatı; akışı okunabilir tutar |
| Veritabanı | PostgreSQL 16 | Durum değişimi ve bildirimin aynı işlemde yazılması (ACID) için |
| Veritabanı erişimi | `postgres` paketi | Parametreli sorgu (SQL Injection'a karşı) |
| Şema yönetimi | Elle SQL dosyaları (`db/migrations/`) | Ek araç gerektirmez |
| Fotoğraf depolama | Sunucu diski, veritabanında yol | İlk sürüm için yeterli; canlıda kalıcı disk gerekir |
| Test | Dart `test` paketi, `mocktail` | Domain ve servis testleri; bir entegrasyon testi |
| Entegrasyon testi | Gerçek PostgreSQL konteyneri | Sahte veritabanı yerine gerçeği test eder |
| Konteyner | Podman, podman-compose | Docker yerine; aynı komut ve compose dosyası |
| Kod kalitesi | `dart analyze`, `flutter analyze`, `dart test --coverage`; Dart taraması için SonarQube Cloud (öneri) | Community'de Dart yok; Cloud denenmedi |
| Dağıtım | VPS üzerinde compose, HTTPS | Deneme ve demo için |

Paket sürümleri pub.dev üzerinde kontrol edildikten sonra bu tabloya eklenir.

## Bileşenler

İstemciler ve yan servisler Dart çekirdeğinin etrafında durur; oklar isteği başlatandan karşılayana doğrudur. Bütün yazma işleri ve kimlik doğrulama çekirdekte kalır; iki yan servis yalnızca okur ([ADR-04](adr/04-cok-dilli-web-ve-servisler.md)). Aynı diyagram [README §5](../README.md#5-mimari)'te.

```mermaid
flowchart LR
    subgraph istemci["İstemciler"]
        mobil["Mobil<br/>Flutter · packages/app"]
        web["Web<br/>HTML/CSS/JS · web/"]
    end
    subgraph cekirdek["Dart çekirdeği (Shelf, :8080)"]
        server["server<br/>HTTP uçları, kimlik, hata eşleme"]
        application["application<br/>kullanım senaryoları"]
        domain["domain<br/>varlıklar ve kurallar"]
        infrastructure["infrastructure<br/>PostgreSQL ve dosya"]
        contracts["contracts<br/>istemcinin okuduğu yanıtlar"]
    end
    python["Python rapor servisi<br/>FastAPI · :8001"]
    csharp["C# istatistik servisi<br/>.NET"]
    db[("PostgreSQL 16")]
    files[("Fotoğraf klasörü<br/>FILES_DIR")]

    mobil -- "REST/JSON + JWT" --> server
    web -- "REST/JSON + JWT" --> server
    python -- "REST/JSON, görevli belirteci" --> server
    mobil -.-> contracts
    server --> application
    server --> infrastructure
    application --> domain
    infrastructure --> application
    infrastructure --> domain
    infrastructure -- "parametreli SQL" --> db
    infrastructure --> files
    csharp -- "salt okunur SQL" --> db
```

- **Mobil ve web** yalnızca çekirdeğin REST API'siyle konuşur; mobil, yanıt sınıflarını `contracts` paketinden okur.
- **Python rapor servisi** çekirdek API'yi görevlinin belirteciyle çağırır ve CSV üretir; veritabanına bağlanmaz.
- **C# istatistik servisi** veritabanını salt okunur bağlantıyla okur, çekirdeğin erişim belirtecini aynı sırla doğrular.

## Katmanlar

Dart çekirdeği dört katmandır: `domain`, `application`, `infrastructure`, `server`. Paket kuralları `test/architecture_test.dart` ile CI'da denetlenir.

```mermaid
flowchart LR
    server --> application
    server --> infrastructure
    infrastructure --> application
    application --> domain
    infrastructure --> domain
```

- **Domain:** varlıklar, değer nesneleri, iş kuralları. Hiçbir katmana bağlı değildir.
- **Application:** kullanım senaryoları (servisler) ve depo arayüzleri (ör. `ReportRepository`). Fotoğraf saklama `infrastructure` içindeki `LocalFileStorage` ile yapılır; sunucu onu doğrudan kullanır.
- **Infrastructure:** PostgreSQL ve dosya sistemi gerçeklemeleri.
- **Server:** HTTP endpoint'leri, kimlik doğrulama, hata eşleme; iş kuralı yazmaz.
- **Bağlama:** bağımlılıklar `packages/server/bin/server.dart` içinde verilir; somut sınıfı yalnızca orası bilir.

Zengin domain nesnesi: `private` alanlar, doğrulama `Create` fabrika metodunda; geçersiz nesne oluşamaz.

## Dil, kapsam ve bilinçli sadeleştirmeler

- **Ölçek:** ders projesi, tek kampüs, birkaç yüz kullanıcı, canlı demo. Bu ölçekte mikroservis, kuyruk ve önbellek **gereksiz karmaşıklık borcudur** (hocanın ders notları, Gün 06). Mimari sınır: **tek dağıtılabilir backend, katmanlı mimari, tek veritabanı** ([kapsam](01-project-scope.md)).
- **Dil:** ders "dil ve framework bağlayıcı değil, hâkim olduğunla git" diyor; ancak ürün **tek dilli** (Dart/Flutter) kalır. Farklı dilde katkı, ürünün içine değil **dağıtıma girmeyen araçlara** (test/QA, seed, benchmark, doküman araçları) yönlendirilir. Böylece herkes güçlü olduğu dilde katkı verirken sistem dağıtık karmaşıklığa sürüklenmez.
- Gerekçe ve karar: [ADR-03](adr/03-katmanli-mimari-ve-tek-dil.md).

## Uyulacak ilkeler

- SOLID ilkeleri, Clean Code prensipleri
- Bir metot bir görev; iç içe koşul yerine erken çıkış
- Sabitler ve limitler kodun içine gömülmez (kampüs sınırı yapılandırmadan gelir)
- Beş ve üzeri parametre yerine istek nesnesi
- Sırlar yalnızca ortam değişkenlerinde ([güvenlik](06-security-and-privacy.md))

## API standartları

- RESTful; kaynaklar çoğul isimle (`/api/reports`)
- Listeleme endpoint'leri sayfalama destekler (`page`, `pageSize`)
- Oluşturma `POST`, güncelleme `PUT`
- Hata gövdesi tek biçimde: `{ "error": { "code", "message", "details" } }`
- JSON alanları `camelCase`

Ayrıntı: [API tasarımı](05-api-design.md).

## Dağıtım

VPS üzerinde `docker-compose.yml` ile backend ve PostgreSQL; fotoğraflar için kalıcı disk; HTTPS. Yapılandırma ve sırlar `.env` ile verilir, repo'ya girmez. Yerelde aynı dosya Podman ile çalışır.
