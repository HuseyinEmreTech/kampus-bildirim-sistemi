---
title: Ekip ve 15 Haftalık Yol Haritası
durum: Onaylandı
son-guncelleme: 2026-10-02
---

# Ekip ve 15 Haftalık Yol Haritası

← [İndeks](00-index.md)

Proje ekiple ve GitHub üzerinden (branch, Pull Request) yürütülür; **herkes kendi yazdığı kodu anlatabilmeli ve kimin ne yaptığı GitHub geçmişinden görülebilmelidir.** Bu doküman ekibin nasıl çalıştığını, GitHub'da neyi nasıl kullandığını ve haftalık hedefleri tanımlar. Kod yapısı ve korumalar: [Kod mimarisi ve korumalar](11-kod-mimarisi-ve-korumalar.md). Yeni katılan biri için: [Başlangıç rehberi](ekip/00-baslangic-rehberi.md).

## 1. Ekip

| Kişi | GitHub | Rol | Ana sorumluluk | Kişisel plan |
| --- | --- | --- | --- | --- |
| Hüseyin Emre | `HuseyinEmreTech` | Teknik lider | `domain`, `application`, `contracts`, CI, kabul testleri, PR incelemesi | [Plan](ekip/huseyin-emre.md) |
| Ertuğrul Pekdemir | `ertrlpkdmr` | Veri ve altyapı | `infrastructure` (PostgreSQL, dosya depolama), SQL, compose; sonra yeni bildirim ekranı | [Plan](ekip/ertugrul-pekdemir.md) |
| Murat Yaman | `yamanmurat761` | Sunucu (API) | `server` (endpoint'ler, kimlik doğrulama, hata eşleme); sonra görevli ekranları | [Plan](ekip/murat-yaman.md) |
| Yusuf Ekenel | (davet edilecek) | Uygulama ve test | Test senaryoları, sahte veri; öğrenci ekranları | [Plan](ekip/yusuf-ekenel.md) |

Görevler, her iş bağımsız ilerleyebilecek ve tek PR'a sığacak büyüklükte kesildi; ilk haftalar herkes için kurulum ve ısınmadır.

## 2. Takvim

- Dönem 15 ders haftası; ders **cuma** günü. 16. haftada ders yok, plana girmez.
- Sprint **Pazartesi-Pazar**. Kapanış **Pazar 23:59**: o haftanın PR'ları birleşmiş, günlük raporlar girmiş olur.
- **Cuma dersi:** herkes bir önceki sprintte ne yaptığını 1 dakikada anlatır; hafta ortası durum konuşulur.
- **Pazartesi:** 15 dakikalık çevrimiçi planlama; o haftanın issue'ları kişilere atanır.
- Tarihlerin dayanağı: 1. hafta 18 Eylül 2026 cuma. **Doğrulanmadı:** sunum tarihleri ve 25 Aralık'ta ders olup olmadığı.

| Hafta | Sprint | Ders | Ortak hedef |
| --- | --- | --- | --- |
| 3 | 28 Eyl - 4 Eki | 2 Eki | Ekip, repo kuralları, kurulum, ilk PR |
| 4 | 5 - 11 Eki | 9 Eki | Repo iskeleti ve CI çalışıyor; domain çekirdeği; veritabanı şeması |
| 5 | 12 - 18 Eki | 16 Eki | **Altın dilim:** "üstlen" (USR 05) uçtan uca; ilk ekran |
| 6 | 19 - 25 Eki | 23 Eki | "Çöz" (USR 06) ve çözüldü bildirimi; giriş |
| 7 | 26 Eki - 1 Kas | 30 Eki | "Bildirim aç" (USR 01): fotoğraf, konum, bina listesi |
| 8 | 2 - 8 Kas | 6 Kas | Uygulama gerçek API'ye bağlanır; yetki testleri |
| 9 | 9 - 15 Kas | 13 Kas | **1. sunum (varsayım)**; ilk SonarQube Cloud taraması |
| 10 | 16 - 22 Kas | 20 Kas | Çözüm fotoğrafı akışı, boş ve hata durumları, sayfalama |
| 11 | 23 - 29 Kas | 27 Kas | Rate limit, kalan işler, bulgular tek tek; dağıtım kararı |
| 12 | 30 Kas - 6 Ara | 4 Ara | **Özellik dondurma (Pazar 6 Ara)**; dağıtım denemesi, APK |
| 13 | 7 - 13 Ara | 11 Ara | Kapsam, ADR'lar, README, dağıtım düzeltmeleri |
| 14 | 14 - 20 Ara | 18 Ara | **Test haftası:** kod donuk, yalnızca hata düzeltme |
| 15 | 21 - 27 Ara | 25 Ara | **Teslim ve 2. sunum (varsayım)**; katkı raporları |

Kişi kişi haftalık görevler kişisel plan dosyalarındadır.

## 3. Öncelik

Geliştirme süresi 9 hafta (4-12). Gecikme olursa kesilecek sıra bellidir:

| Öncelik | İçerik |
| --- | --- |
| **Şart** | Giriş; fotoğraf ve konumla bildirim açma (GPS, izin yoksa bina listesi); görevli listesi; üstlen; çöz ve **sonuç fotoğrafı**; öğrenciye çözüldü bildirimi; Rule 00-07; PostgreSQL; Android demo; testler |
| **Olmalı** | Bildirimlerim ekranı, sayfalama, EXIF temizleme, rate limit, SonarQube Cloud |
| **Olursa** | VPS ve HTTPS, `assignee=me` filtresi, 30 gün sonra fotoğraf silme, ekran cilası, Codecov |

Kural ve test hiçbir zaman kesilmez; önce "olursa" satırı kesilir. Dağıtım kararı hafta 11 sonunda verilir: VPS yoksa sunum yerel sunucu ve telefonla yapılır ve README'de açıkça yazılır.

## 4. GitHub'da ne kullanıyoruz

| Araç | Ne için | Kural |
| --- | --- | --- |
| **Issue** | Her görev bir kart | Şablonla açılır: kabul ölçütü, dokunulacak ve dokunulmayacak dosyalar, bağlı testler. Bir kişiye atanır |
| **Milestone** | Her hafta bir milestone (`Hafta 04` ...) | Issue haftasına bağlanır; Pazar günü kapanır |
| **Etiketler** | Katman ve tür | Katman: `domain`, `application`, `contracts`, `infrastructure`, `server`, `app`, `docs`, `ci`. Tür: `feat`, `fix`, `test`, `docs`. Öncelik: `sart`, `olmali`, `olursa` |
| **Projects (Kanban)** | Haftanın durumu tek bakışta | Sütunlar: Yapılacak, Yapılıyor, İncelemede, Bitti |
| **Branch** | Her issue kendi branch'inde | Ad: `feature/<issue-no>-<kisa-ad>`, `fix/...`, `docs/...`, `test/...` |
| **Pull Request** | Tek yol `main`'e | Şablon doldurulur, `Closes #<issue-no>` yazılır; CI yeşil ve 1 onay olmadan birleşmez; squash ile birleşir |
| **CODEOWNERS** | Çekirdek koruması | `domain`, `application`, `contracts`, `test/`, `.github/`, `AGENTS.md` değişikliği Hüseyin Emre onayı ister |
| **Actions (CI)** | Otomatik kontrol | Biçim, analiz, mimari test, testler |
| **Releases** | Demo APK | Hafta 12 ve 15'te APK sürüm olarak yayımlanır |

Yapılmayanlar: Wiki (dokümanlar repoda), Discussions (konuşma issue'larda ve PR'larda).

## 5. Birlikte çalışma kuralları

1. **Bir issue, bir branch, bir PR.** PR küçük tutulur (ideal 300 satırın altı, test dahil).
2. **Başkasının adına commit yok.** Herkes kendi hesabıyla commit atar; hoca GitHub geçmişinden kimin ne yaptığını görür.
3. **Her hafta en az bir birleşmiş PR**, herkes için.
4. **Yapay zeka ile kodlama serbest, anlamadan almak yasak.** Kural seti: [AGENTS.md](../AGENTS.md); nasıl çalışılacağı: [Başlangıç rehberi](ekip/00-baslangic-rehberi.md#5-yapay-zeka-ile-nasıl-çalışıyoruz).
5. **Anlatabilme kontrolü.** İnceleyen her PR'da en az bir "bu satır neden böyle?" sorusu sorar; yazar kendi cümlesiyle cevaplar. Hoca sorduğunda herkes kendi kodunu anlatabilmelidir.
6. **Kabul testi önce.** Kural içeren görevlerde test Hüseyin Emre tarafından önceden yazılır (`bekliyor` etiketi); görev testi yeşile çevirmektir. Test değiştirilmez; değişmesi gerekiyorsa issue'da konuşulur.
7. **Dokunulmayacak dosyalar listesine uyulur.** Gerekirse önce issue'da sorulur.
8. **Sır yok.** Şifre, token, gerçek öğrenci verisi ve `.env` commit'e girmez.
9. **Takılınca 30 dakika kuralı.** 30 dakikadan fazla takılan, issue'ya ne denediğini yazar ve yardım ister.

## 6. Kayıt sistemi

| Kayıt | Kim yazar | Ne zaman |
| --- | --- | --- |
| PR açıklaması (şablon) | PR'ı açan | Her PR; commit başına kayıt yerine geçer |
| **Günlük rapor** (`ekip/raporlar/<kişi>/YYYY-AA-GG.md`, [şablon](Templates/gunluk-rapor.md)) | Herkes yalnızca kendi klasörüne | Çalışılan her gün; o günün PR'ıyla birlikte. Ne yaptım, ne yapamadım ve neden, plandan ne değişti, hangi tercihi neden yaptım, yapay zeka, takıldığım yer, sıradaki. Katkı raporunun kaynağı |
| Haftalık kayıt (`haftalik/`) | Hüseyin Emre | Her Pazar; birleşen PR listesinden derlenir |
| Hata, teknoloji, SonarQube, Skill kayıtları (`kayitlar/`) | İlgili PR'ın sahibi | Olduğu PR'da |
| ADR (`adr/`) | Hüseyin Emre (taslağı herkes önerebilir) | Geri dönülmesi zor kararda |

Herkes yalnızca kendi dosyasına yazdığı için kayıtlarda merge çakışması çıkmaz.

## 7. Açık sorular

| Soru | Kime | Durum |
| --- | --- | --- |
| Sunum tarihleri ve biçimi | Hoca | Açık |
| Teslim dersi 25 Aralık mı | Hoca | Açık |
| Dart için SonarQube Cloud kabul mü ([ADR-02](adr/02-kalite-araci-sonarqube-cloud.md)) | Hoca | Açık |
| Yusuf Ekenel'in GitHub kullanıcı adı ve daveti | Ekip | Açık |
| VPS var mı | Ekip | Hafta 11'de karar |
