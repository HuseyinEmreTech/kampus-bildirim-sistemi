---
title: "ADR-04: Çok Dilli Yüzeyler (Web, Python ve C# Servisleri)"
durum: Önerildi (C# ayağı uygulandı)
son-guncelleme: 2026-11-01
---

# ADR-04: Çok Dilli Yüzeyler (Web, Python ve C# Servisleri)

← [ADR şablonu](00-adr-template.md) · [ADR-03](03-katmanli-mimari-ve-tek-dil.md) · [İndeks](../00-index.md)

## Durum

**Önerildi; kısmen uygulandı (2026-10-31).** C# istatistik servisi `services/rapor-istatistik/` olarak birleşti; Python rapor servisi incelemede. Hocanın beklentisinin "deneme" mi yoksa "zorunlu çok dilli ürün" mü oldüğü hâlâ netleşmedi; bu yüzden ADR "Önerildi"den "Kabul edildi"ye taşınmadı. Uygulanan kısım geri alınabilir olacak şekilde ayrı `services/` klasöründe duruyor.

## Bağlam

- ADR-03 tek dilli ürünü (Dart/Flutter + Dart/Shelf) ve çok dilli katkının yalnızca **ürün dışı araçlarda** olmasını seçmişti.
- Hoca, öğrencilerin **farklı bir mimaride nerede zorlandığını görmek** istiyor; ders notlarında dili serbest bırakıyor ("hâkim olduğunla git").
- Ekip 7 kişiye çıktı ve dil tercihleri dağınık:
  - Dart: Yusuf, Hüseyin, Çağdaş, Ertuğrul
  - C#: Murat, Hüseyin, Müberra, Çağdaş
  - Python: Müberra, Çağdaş
  - HTML/CSS: Murat
- Herkesin yalnızca Dart öğrenmeye zorlanması motivasyonu ve katkıyı düşürüyor; hocanın görmek istediği "mimari deneyimi" de oluşmuyor.
- Mevcut Dart çekirdeği çalışıyor: veri katmanı, auth, JWT, dosya/EXIF, migration'lar, CI ve testler.

## Karar

**Çekirdek sabit, kenarlar çok dilli.**

1. **Çekirdek ürün Dart'ta kalır:** Dart/Shelf + PostgreSQL; raporlar, auth, dosya, transaction gerektiren tüm işler (Rule 04).
2. **Web istemcisi ayrı ve HTML/CSS/JS** olur; çekirdeğin REST API'sini tüketir. (Murat)
3. **Python servisi** eklenir: bildirim/rapor dışa aktarma gibi **tek yönlü** işler (FastAPI). (Müberra)
4. **C# servisi** eklenir: rapor dışa aktarma/istatistik gibi **okuma ağırlıklı** işler (.NET). (Çağdaş)
5. **Mobil** Flutter/Dart kalır. (Yusuf)
6. **Veri katmanı** Dart + PostgreSQL'de kalır. (Ertuğrul)
7. **QA/E2E** Python/araçlarla yapılır. (Kerem)
8. **Sözleşme:** Tüm yüzeyler `05-api-design.md` ve JSON üzerinden konuşur; yeni servisler birbirine yalnızca API ile bağlanır.

### Sınır ilkeleri

- **Transaction gerektiren işler çekirdekte kalır.** Bildirim + durum geçmişi + çözüm aynı işlemde yazılmaya devam eder (Rule 04). Bu yüzden dağıtık transaction yok.
- Yeni servisler **tek yönlü** veya **salt okunur**; çekirdeğin veritabanına yazmaz.
- Her yeni servis kendi Docker imajı, health check'i ve CI işiyle gelir; entegrasyonu Hüseyin yürütür.
- **Auth Dart'ta kalır.** Çalışan JWT akışını C#'a taşımak gereksiz risk; C# servisi auth'a bağımlı olacaksa çekirdeğin token doğrulamasını kullanır.

## Neden bu değişiklik? (hocaya özet)

- **Öğrenme hedefi:** Hocanın istediği "farklı mimariyi deneyip zorlandığımız yeri görme" ancak gerçek bir çok dilli yüzeyle olur.
- **Ekip uyumu:** Herkes kendi güçlü olduğu dilde çalışır; 7 kişilik ekipte motivasyon ve katkı artar.
- **Düşük risk:** Çalışan Dart çekirdeği ve veritabanı korunur; değişiklik kenarlarda ve yeni servislerde olur. Geri dönüş kolaydır (servisi kapat, çekirdek çalışmaya devam eder).
- **Hocanın değerlendirme kriterleri:** README'de mimari, zorluklar ve çözümler isteniyor; bu ADR ve servis bazlı notlar tam olarak bunu belgeler.

## Alternatifler

| Seçenek | Değerlendirme |
| --- | --- |
| ADR-03'te kalmak (tek dil) | En düşük risk, ama hocanın istediği mimari deneyimi ve ekip dil tercihi karşılanmaz. |
| Tüm ürünü Python'a taşımak | Çalışan Dart sunucusu, JWT, depolar, CI çöpe gider; 15 haftada yetişmez. Reddedildi. |
| Tam mikroservis (7 servis) | Dağıtık transaction, servis keşfi, çoklu CI/deploy; ders projesi için aşırı. Reddedildi. |
| **Çekirdek + sınırlı çok dilli yüzeyler (bu ADR)** | Öğrenme hedefini karşılar, risk sınırlı. Seçildi. |

## Sonuçlar

### Avantajlar

- Hocanın görmek istediği mimari deneyimi ve "nerede zorlandık" kaydı oluşur.
- Herkes kendi dilinde çalışır; 7 kişilik ekipte iş bölümü kolaylaşır.
- Çekirdek ve veri bütünlüğü korunur.

### Riskler ve önlemler

| Risk | Önlem |
| --- | --- |
| Servisler arası tutarsızlık | Transaction gerektiren iş yok; servisler tek yönlü/salt okunur |
| Çoklu deploy/CI yükü | Her servis Docker + health check; Hüseyin entegrasyon sahibi |
| Auth'un dağılması | Auth Dart çekirdekte kalır |
| Süre yetmemesi | Python/C# servisleri "olursa" kapsamında; süre sıkışırsa kapatılır, çekirdek teslim edilir |
| Kapsamın dağılması | Öncelik sırası korunur (10-ekip bölüm 3) |

## Açık sorular

- Hoca mikroservisi **zorunlu** mu tutuyor, yoksa "deneyin" mi diyor?
- Python/C# servisleri teslim kapsamında mı, yoksa deneme/retrospektif mi?
- ~~Web istemcisi Flutter Web'in yerini mi alacak, yoksa yanında mı duracak?~~ Öneri (2026-11-01): yerini alır, `lib/web/` dondurulur ([plan](../planlar/2026-11-01-kalan-isler.md)).

## Değişiklik geçmişi

| Tarih | Değişiklik |
| --- | --- |
| 2026-10-21 | İlk taslak. ADR-03'ün yerini kısmen alır; çekirdek Dart, kenarlar çok dilli. |
| 2026-11-01 | Web yüzeyi önerisi: HTML/JS istemcisi Flutter Web'in yerini alır; `lib/web/` dondurulur. |
