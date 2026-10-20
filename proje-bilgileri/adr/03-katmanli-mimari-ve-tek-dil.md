---
title: "ADR-03: Katmanlı Mimari ve Tek Dilli Ürün"
durum: Yerini ADR-04 aldı (kısmen)
son-guncelleme: 2026-10-21
---

# ADR-03: Katmanlı Mimari ve Tek Dilli Ürün

← [ADR şablonu](00-adr-template.md) · [ADR-01](01-dart-backend-postgresql.md) · [ADR-02](02-kalite-araci-sonarqube-cloud.md) · [İndeks](../00-index.md)

## Durum

**Yerini kısmen [ADR-04](04-cok-dilli-web-ve-servisler.md) aldı (2026-10-21).** Çekirdek ürün Dart'ta kalıyor; ancak web istemcisi, Python servisi ve C# servisi gibi çok dilli yüzeyler ADR-04 ile ekleniyor. Bu ADR tarihsel kayıt olarak durur; silinmez.

## Bağlam

- Proje küçük: tek kampüs, birkaç yüz kullanıcı, canlı demo, 15 haftalık ders projesi ([kapsam](../01-project-scope.md)).
- Ekip 6 kişi; herkesin ilgi ve teknoloji alanı farklı. Bazı üyeler farklı bir dilde çalışmak isteyebiliyor.
- Hocanın ders notları dil konusunda serbest bırakıyor: **"Dil ve framework bağlayıcı değil, hâkim olduğunla git."** Yani tek dil zorunluluğu yok.
- Ancak hoca aynı zamanda küçük ölçekli projelerde dağıtık mimariye erken geçmeyi **"gereksiz karmaşıklık borcu"** olarak niteliyor (ders notları, Gün 06): *"Dağıtık sistemlere geçiş her zaman doğru karar değildir... projenin gerçekten bu ölçeklenebilirliğe ihtiyaç duyup duymadığını sorgulamak..."* Gün 05 mimari tablosunda da dağıtık mimariler Elastikiyet/Dayanıklılık'ta yüksek ama **Maliyet ve Basitlik'te düşük** puan alıyor.
- Kendi proje spesifikasyonumuz zaten şunu yazıyor: **"tek dağıtılabilir backend, katmanlı mimari, tek veritabanı. Mikroservis, kuyruk ve önbellek yok."**
- Değerlendirme kriterleri (hoca): Clean Code, SOLID, **mimari uyum**, okunabilirlik, test edilebilirlik; README'de **mimari, zorluklar ve çözümler**.

## Seçenekler

| Kod | Seçenek | Kısaca |
| --- | --- | --- |
| A | Katmanlı monolit, tek dil (Dart/Flutter) | Mevcut durum. Kişi başına dil sabit ama net katman ve sahiplik var. |
| B | Çok dilli ürün: herkes kendi dilinde, ayrı servisler | Ürün birden çok sürece bölünür → servisler arası sözleşme, dağıtım, auth, hata yönetimi karmaşıklığı (dağıtık). |
| C | Katmanlı monolit + dağıtıma girmeyen çok dilli araçlar | Ürün tek dil; test/QA, seed, benchmark, doküman gibi yerel araçlar başka dilde olabilir. |

## Karar

**A + C.**

1. **Ürün** tek dağıtılabilir ve **tek dilli** kalır (istemci Flutter/Dart, sunucu Dart/Shelf). Katmanlı mimari korunur ([11-kod-mimarisi-ve-korumalar](../11-kod-mimarisi-ve-korumalar.md)).
2. **"Herkes kendi dilinde" esnekliği**, ürüne girmeyen araçlarla verilir: test/QA scriptleri, seed/benchmark, doküman ve otomasyon araçları başka dilde yazılabilir. Bu, hocanın kendi dersindeki desenle aynı (ürün .NET, RAG/MCP araçları Python).
3. **Ürünü çok dilli servislere bölmek (Seçenek B) şimdilik reddedilir.** Gerçek bir ihtiyaç doğarsa (ör. ayrı bir AI/ML servisi) bu ADR "Yerini ADR-NN aldı" ile güncellenir.

## Sonuçlar

### Avantajlar

- Hocanın "gereksiz karmaşıklık borcu" uyarısına ve kendi kapsam sınırımıza uyum.
- Tek deploy, tek veritabanı, tek dil → CI, test ve analiz basit kalır.
- Her üyenin zaten bir şeridi var: `domain`, `application`, `contracts`, `infrastructure`, `server`, `app` ([koruma katmanları](../11-kod-mimarisi-ve-korumalar.md#2-paketler-ve-izinli-bağımlılıklar)).
- Farklı dil tercihi olan üye, katkısını araçlara yönlendirerek hem kendi güçlü olduğu dilde çalışır hem "zorluklar ve çözümler" kaydını zenginleştirir.

### Değiş tokuşlar

- Üründe farklı dilde kod isteyen üye, isteğini ürüne değil araçlara yönlendirir.
- Ürün içinde tek dilden memnun olmayan üye için motivasyon, sahiplik ve araç katkısıyla dengelenir.
- Araçlar ürünle aynı dilde olmadığı için bakımı ayrı bir beceri gerektirir (küçük script'ler olduğu için kabul edilebilir).

## Alternatiflerin değerlendirmesi

- **B (çok dilli ürün)** reddedildi: dağıtık karmaşıklık (ağ hataları, dağıtık sistem yanılgıları, nihai tutarlılık) bu ölçekte getirisinden fazla; ayrıca Auth/CORS/sözleşme yönetimi çoğalır. Hoca ve spec bunu gereksiz buluyor.
- **Saf A (araçlarda da tek dil)** reddedildi: dil esnekliği tamamen kaybolur; oysa hoca dili serbest bırakıyor ve ekip içinde farklı ilgi alanları var.

## Açık sorular

- Ekip: ürün tek dil kalsın mı? "Dağıtıma girmeyen araçlar" ayrımı yeterli mi?
- Kerem (Emir Kerem Çakıcı) hangi alanı üstlenmek ister? Öneriler: test & QA, `contracts` (DTO'lar), ya da bir uçtan uca özellik dilimi.
- İleride ayrı bir AI destek servisi (ör. kategori önerisi) gündeme gelirse ayrı bir ADR ile değerlendirilir mi?

## Değişiklik geçmişi

| Tarih | Değişiklik |
| --- | --- |
| 2026-10-15 | İlk taslak, durum: Önerildi. Hocanın ders notları (dil serbest; dağıtık = gereksiz karmaşıklık borcu) temel alındı. |
| 2026-10-21 | Durum "Yerini ADR-04 aldı (kısmen)". Çekirdek Dart; web/Python/C# yüzeyleri ADR-04 ile eklendi. |
