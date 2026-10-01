---
title: "ADR-01: Dart Backend ve PostgreSQL"
durum: Kabul edildi
son-guncelleme: 2026-10-02
---

# ADR-01: Dart Backend ve PostgreSQL

← [ADR şablonu](00-adr-template.md) · [İndeks](../00-index.md)

## Durum

**Kabul edildi (2 Ekim 2026).** Hoca 1 Ekim e-postasında teknoloji seçimini "yerinde" buldu; ekip 4 kişi, süre 15 ders haftası. Dart için SonarQube sorusu [ADR-02](02-kalite-araci-sonarqube-cloud.md)'de açık.

## Bağlam

Proje bir Flutter (Dart) istemcisi ve bir backend gerektiriyor. Backend dili ve veritabanı geri dönülmesi zor kararlardır: domain, veri erişimi ve testler bunlara göre yazılır. Ders şartı en az bir veritabanı (SQL, NoSQL veya bellek içi) kullanılmasıdır. Hâkim olunan dil tercih edilir; kodun akışını anlamak en büyük zorluktur.

Kritik iş kuralları:

- Bir bildirimi aynı anda tek görevli üstlenir ([Rule 02](../03-domain-design.md#kurallar-rules)).
- Durum değişimi ve öğrenci bildirimi tek işlemde yazılır ([Rule 04](../03-domain-design.md#kurallar-rules)).

## Seçenekler

| Seçenek | Artı | Eksi |
| --- | --- | --- |
| **Dart backend (Shelf) + PostgreSQL** | Tek dil, aynı model sınıfları; katmanlı mimari görünür; ACID işlem ve koşullu güncelleme kuralları doğal karşılar; VPS'e Podman ile kurulur | Dart backend ekosistemi küçük; **SonarQube Community'de Dart dili yok** (30 Eylül'de doğrulandı) |
| Firebase | Hızlı başlangıç; kimlik doğrulama ve depolama hazır | Backend mimarisi büyük ölçüde gizlenir; Rule 02 ve Rule 04 güvenlik kuralları ve işlemlerle çözülür; VPS dağıtımının anlamı kalmaz; ders şartını sağlar |
| Serverpod | Postgres ve Flutter kod üretimi hazır | Çok şeyi gizler; akışı anlamak ve gereksiz karmaşıklığı önlemek ilkelerine ters |
| Başka dilde backend (örn. Python, Node.js) | Geniş ekosistem ve örnek | İki dil hâkimiyeti gerekir |

## Karar (öneri)

**Dart (Shelf) ve PostgreSQL.** Tek dilin avantajı, kritik kuralların veritabanı işlemleriyle doğal çözülmesi ve mimarinin kod içinde görünür kalması gerekçedir.

## Sonuçlar

**Avantajlar**

- İstemci ve sunucu aynı dil; iki dil hâkimiyeti gerekmez.
- Rule 02 ve Rule 04 veritabanı işlemleriyle doğrulanabilir testlerle karşılanır.
- Entegrasyon testi gerçek PostgreSQL konteyneriyle yapılabilir.

**Değiş tokuşlar**

- Dart backend için örnek ve yapay zeka desteği C# veya Python kadar bol olmayabilir; çıktı daha dikkatli okunur.
- **SonarQube Community Dart'ı taramıyor** (yerelde doğrulandı). Resmi Dart desteği Developer Edition ve **SonarQube Cloud**'da var; herkese açık projeler için Cloud ücretsiz planı kullanılabilir. Bu yüzden SonarQube alışkanlığı korunabilir ama bulut hizmetine bağımlılık ve yalnızca `main`/`main`'e PR analizi kısıtı vardır ([araştırma](../kayitlar/sonarqube-puanlari.md#dart-desteği-araştırması-2026-09-30)). Yerelde `dart analyze`, `flutter analyze` ve test kapsamı ile desteklenir.
- Paket sürümleri ve güncellikleri pub.dev'de kontrol edilmelidir.

## Açık sorular

- ~~Hocanın görüşü: Dart backend kabul mü?~~ Cevaplandı: teknoloji seçimi uygun (1 Ekim 2026).
- SonarQube Cloud (ücretsiz plan) ile Dart taraması kabul mü, yoksa yerel SonarQube mi bekleniyor?

## Değişiklik geçmişi

| Tarih | Değişiklik |
| --- | --- |
| 2026-09-30 | İlk taslak, durum: Önerildi |
| 2026-09-30 | SonarQube doğrulandı: Community'de Dart dili yok; değiş tokuş ve açık soru güncellendi |
| 2026-09-30 | İnternet araştırması: Dart desteği Developer Edition ve SonarQube Cloud'da var; ücretsiz Cloud planı öneriliyor |
| 2026-10-02 | Durum: Kabul edildi (hoca olumlu yanıt, ekip kuruldu); C# (ASP.NET) alternatifi yeniden değerlendirildi (derleyiciyle katman koruması, yerel SonarQube); Dart'ta kalındı: tek dil, ekipte iki Dart bilen; katman koruması paket bağımlılıkları ve mimari testle sağlanır ([korumalar](../11-kod-mimarisi-ve-korumalar.md)) |
