---
title: Proje Bilgileri Vault'u
durum: Güncel
son-guncelleme: 2026-10-02
---

# Campus Report: Proje Bilgileri

← [Ana README](../README.md) · [Doküman indeksi](00-index.md)

Bu klasör **Campus Report** projesinin bütün dokümantasyonudur: ne yaptığımız, nasıl yaptığımız, kimin ne yaptığı ve hangi kararı neden aldığımız. Hem GitHub'da okunur hem de [Obsidian](https://obsidian.md) vault'u olarak açılır; bağlantılar standart Markdown olduğu için ikisinde de aynı çalışır.

**Proje bir cümlede:** öğrenci kampüste gördüğü sorunu fotoğraf ve konumla bildirir, görevli "ilgileniyorum" diyerek üstlenir ve sonuç fotoğrafıyla çözer, çözülünce öğrenciye uygulamada haber gider.

## 1. Kim, nereden başlamalı?

### Hocamız için

| Ne görmek isterseniz | Nereye bakın |
| --- | --- |
| Projenin amacı, kapsamı ve sınırları | [01 Proje kapsamı](01-project-scope.md) |
| Ekip, kimin neden sorumlu olduğu, 15 haftalık takvim | [10 Ekip ve yol haritası](10-ekip-ve-yol-haritasi.md) |
| Her üyenin hafta hafta görevleri ve günlük raporları (ne yaptı, ne yapamadı, ne değişti, neyi neden seçti) | [Hüseyin Emre](ekip/huseyin-emre.md), [Ertuğrul Pekdemir](ekip/ertugrul-pekdemir.md), [Murat Yaman](ekip/murat-yaman.md), [Yusuf Ekenel](ekip/yusuf-ekenel.md) |
| Mimari ve hataları önleyen korumalar | [02 Mimari genel bakış](02-architecture-overview.md), [11 Kod mimarisi ve korumalar](11-kod-mimarisi-ve-korumalar.md) |
| Domain, iş kuralları (Rule 00-07) | [03 Domain tasarımı](03-domain-design.md) |
| Geri dönülmesi zor kararlar | [ADR-01 Dart ve PostgreSQL](adr/01-dart-backend-postgresql.md), [ADR-02 Kod kalitesi aracı](adr/02-kalite-araci-sonarqube-cloud.md) |
| Yapay zekayı nasıl kullandığımız | [09 Yapay zeka kullanımı](09-ai-usage.md), [AGENTS.md](../AGENTS.md), [Skill kataloğu](kayitlar/skill-katalogu.md) |
| Haftadan haftaya ilerleme | [Haftalık kayıtlar](haftalik/00-haftalik-index.md) |
| Yapılan hatalar ve dersler | [Hata kayıtları](kayitlar/hata-kayitlari.md) |
| Kod kalitesi puanları | [SonarQube puanları](kayitlar/sonarqube-puanlari.md) |

Kimin ne yaptığı GitHub'da da izlenebilir: her iş bir issue, her issue bir kişiye atanmış ve bir haftaya (milestone) bağlı, her değişiklik o kişinin açtığı Pull Request ile gelir.

### Ekip arkadaşları için

1. **İlk gün:** [Başlangıç rehberi](ekip/00-baslangic-rehberi.md): kurulum, Git akışı komut komut, yapay zeka ile nasıl çalıştığımız.
2. **Kendi planın:** `ekip/` altında adının yazdığı dosya. Bu hafta ne yapacağın, dokunmayacağın yerler ve hocanın sana sorabileceği sorular orada.
3. **Kurallar:** [Kod mimarisi ve korumalar](11-kod-mimarisi-ve-korumalar.md) (kod nereye yazılır) ve [AGENTS.md](../AGENTS.md) (yapay zeka aracına verdiğin kurallar).
4. **Görevin:** GitHub'da sana atanmış issue. Issue'daki kabul ölçütü ve dosya listesi esastır.
5. **Çalıştığın her gün:** [şablonla](Templates/gunluk-rapor.md) günlük rapor yaz (`ekip/raporlar/<adın>/YYYY-AA-GG.md`): ne yaptın, ne yapamadın, ne değişti, neyi neden tercih ettin, yapay zeka, takıldığın yer.

### Yapay zeka araçları için

Önce [AGENTS.md](../AGENTS.md), sonra [11 Kod mimarisi ve korumalar](11-kod-mimarisi-ve-korumalar.md), sonra görevin issue metni. Ölçek ve sınırlar: [01 Proje kapsamı, bölüm 7](01-project-scope.md#7-ölçek-ve-kısıtlar-proje-bağlamı).

## 2. Kim ne yapıyor? (özet)

| Kişi | Rol | Paketler | İlk iki hafta | Plan |
| --- | --- | --- | --- | --- |
| **Hüseyin Emre** | Teknik lider | `domain`, `application`, `contracts`, CI | Repo iskeleti ve korumalar; domain çekirdeği; GitHub düzeni | [Plan](ekip/huseyin-emre.md) |
| **Ertuğrul Pekdemir** | Veri ve altyapı | `infrastructure`, `db/`, `compose.yaml` | Kurulum; PostgreSQL konteyneri; SQL şeması ve sahte seed verisi | [Plan](ekip/ertugrul-pekdemir.md) |
| **Murat Yaman** | Sunucu (API) | `server`, `contracts` yazımı | Kurulum; C#'tan Dart'a geçiş; kampüs sınırı ve bina listesi; API sözleşme sınıfları | [Plan](ekip/murat-yaman.md) |
| **Yusuf Ekenel** | Uygulama ve test | `app` (öğrenci ekranları), test senaryoları | Kurulum ve Git; test senaryoları ve sahte veri listesi | [Plan](ekip/yusuf-ekenel.md) |

Hafta 8'den sonra Ertuğrul yeni bildirim ekranını, Murat görevli ekranlarını yazar; Yusuf her hafta bir öğrenci ekranı yapar. Hafta 14 test haftasıdır, hafta 15'te teslim edilir.

## 3. Klasör haritası

| Klasör / dosya | İçerik | Kim günceller |
| --- | --- | --- |
| `00-index.md` | Bütün dokümanların listesi, terimler, açık kararlar | Hüseyin Emre |
| `01` - `09` | Tasarım dokümanları: kapsam, mimari, domain, hikayeler, API, güvenlik, ortam, süreç, yapay zeka | Davranışı değiştiren PR'ın sahibi, aynı PR'da |
| `10-ekip-ve-yol-haritasi.md` | Ekip, takvim, öncelik, GitHub kullanımı, çalışma kuralları | Hüseyin Emre |
| `11-kod-mimarisi-ve-korumalar.md` | Paketler, izinli bağımlılıklar, korumalar, test düzeni | Hüseyin Emre |
| `ekip/` | Başlangıç rehberi, kişi başına plan | **Herkes yalnızca kendi dosyasını** |
| `ekip/raporlar/<kişi>/` | Kişinin günlük raporları, tarih adlı | **Yalnızca o kişi** |
| `planlar/` | Kodlama işlerinin adım adım uygulama planları | İşi planlayan |
| `adr/` | Mimari karar kayıtları; silinmez, değişirse "Yerini ADR-NN aldı" | Hüseyin Emre |
| `haftalik/` | Her haftanın kararları ve birleşen PR'ları | Hüseyin Emre, her Pazar |
| `kayitlar/` | Teknoloji değişiklikleri, hata kayıtları, SonarQube puanları, Skill ve araç kullanımı | İlgili PR'ın sahibi |
| `Templates/` | Haftalık dosya ve günlük rapor şablonları | |

## 4. Bu vault'u nasıl incelersiniz?

**GitHub'da:** bu sayfadaki bağlantılarla gezin. Mermaid diyagramları (durum akışı, katmanlar) GitHub'da çizilir.

**Obsidian'da:**
1. Repo'yu klonlayın: `git clone https://github.com/HuseyinEmreTech/kampus-bildirim-sistemi.git`
2. Obsidian → **Open folder as vault** → `kampus-bildirim-sistemi/proje-bilgileri` klasörünü seçin (repo kökünü değil).
3. Başlangıç sayfası olarak bu dosyayı veya `00-index.md`'yi açın. **Graph view** dokümanların birbirine nasıl bağlandığını gösterir.

**Bir dokümanın güncel olup olmadığını anlamak:** her dosyanın başındaki `durum` (Taslak, Onaylandı, Güncel) ve `son-guncelleme` alanlarına bakın. Davranışı değiştiren her PR ilgili dokümanı da aynı PR'da günceller.

**Doğrulanmamış bilgi:** dokümanlarda "doğrulanmadı" ya da "varsayım" yazan her şey henüz kanıtlanmamıştır (ör. sunum tarihleri). Kanıtlananlar tarih ve yöntemle yazılır.

## 5. Dokümantasyon kuralları (yazanlar için)

1. Dosya adı: sıra numarası veya tarih + kebab-case, Türkçe karakter yok. İçerik Türkçe.
2. Her dosyanın başında front matter (`title`, `durum`, `son-guncelleme`) ve en üstte `←` geri bağlantısı.
3. Bağlantılar standart Markdown: `[metin](dosya.md)`. Wikilink (`[[...]]`) yok, klasöre değil dosyaya bağlantı.
4. Davranış değişiyorsa doküman aynı PR'da güncellenir; `son-guncelleme` değişir.
5. Kişisel not, şifre, gerçek öğrenci verisi bu klasöre yazılmaz.
6. Doküman ekleyince kırık bağlantı kontrolü: `obsidian vault=proje-bilgileri unresolved` (Obsidian açıkken).
