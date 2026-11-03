---
title: 2026-11-01 Görev Dağılımı ve Dokümantasyon Denetimi
durum: Güncel
son-guncelleme: 2026-11-01
---

# 2026-11-01 Görev Dağılımı ve Dokümantasyon Denetimi

← [İndeks](../00-index.md) · [Kalan işler planı](../planlar/2026-11-01-kalan-isler.md) · [Hata kayıtları](hata-kayitlari.md)

1 Kasım 2026'da proje baştan tarandı, kalan işler kişilere dağıtıldı ve ekibin dokümantasyonu denetlendi.

## Ne yapıldı

- **Durum tespiti:** kod, dokümanlar, issue ve PR'lar tarandı. Parçalar `main`'de ama birbirine bağlı değil: rapor uçları `bin/server.dart`'a bağlanmamış, mobil uygulamada HTTP kaynağı yok, Rule 06'nın kampüs sınırı denetlenmiyor, fotoğrafları sunan bir uç yok.
- **Plan:** [Kalan işler planı](../planlar/2026-11-01-kalan-isler.md) yazıldı. Vize dönemi nedeniyle son tarih konmadı; sıra yalnızca bağımlılığa göre.
- **Issue'lar:** 21 yeni issue açıldı (#163-#183), #93, #94, #159 ve #160 yeniden yazıldı; 25 görevin hepsi bir kişiye atandı.
- **Milestone:** haftalık 14 milestone kapatıldı, silinmedi.
- **Dokümanlar:** yol haritası, başlangıç kuralları, görev dağılımı, kişisel planlar, ADR-04 ve kod mimarisi yeni düzene çekildi.

## Kararlar

| Karar | Gerekçe |
| --- | --- |
| Web yüzeyi `web/` (HTML/JS); `lib/web/` Flutter Web dondurulur | İki web istemcisini yetiştirecek kapasite yok |
| Mobil için `http` paketi | Multipart isteği elle yazmamak için; #170'te teknoloji kaydına girer |
| `campus_contracts` yalnızca istemcinin okuduğu yanıtları içerir | Sunucu mapper'ları çalışıyor; uyumu E2E testleri korur |
| Fotoğrafı öğrenci yalnızca kendi bildiriminde, görevli hepsinde görür | Rule 01 |
| Demo backend silinir | Yedek plan yerel sunucudur |
| HTTPS: VPS varsa Caddy, yoksa yerel ağda demo | Dağıtım kararı henüz verilmedi |

## Dokümantasyon denetimi

Ölçütler [yol haritası bölüm 6](../10-ekip-ve-yol-haritasi.md#6-kayıt-sistemi), [PR şablonu](../../.github/pull_request_template.md) ve [günlük rapor şablonu](../Templates/gunluk-rapor.md).

| Ölçüt | Ekip toplamı |
| --- | --- |
| Birleşen PR'da yapay zeka bölümü | 109 / 122 PR'da var, 108'inde araç satırı dolu |
| Token alanı dolu (alan 24 Ekim'de eklendi; sonrası sayıldı) | 50 / 56 |
| PR'da doküman kutusu işaretli | 65 / 122 |
| PR açılan günlerden günlük raporu olan | 20 / 36 |
| Günlük raporda token bilgisi | 16 / 27 |
| Kişisel planda en az bir işaretli hedef | 3 / 7 kişi |
| Kişisel planda rapor bağlantısı | 4 / 7 kişi |

**Sınırlar.** Sayılar betikle, metin eşleştirerek çıkarıldı; içerik doğruluğu okunmadı. PR açılan gün çalışılan günü yalnızca yaklaşık gösterir. Kutusu işaretsiz bir PR dokümanı yine de güncellemiş olabilir.

### Ekip genelinde bulunanlar

- Günlük raporlar birçok kişide PR'ların gerisinde kaldı; 31 Ekim-1 Kasım turundaki işlerin çoğunun raporu yok.
- [Haftalık kayıtlar](../haftalik/00-haftalik-index.md) 3. haftada kalmış.
- [Yapay zeka kullanımı](../09-ai-usage.md) review süresi tablosu hâlâ "Henüz PR yok" diyor.
- Kişisel planların çoğunda hedef kutuları işaretlenmemiş; yapılan iş plandan okunamıyor.
- Rapor klasörü adları plan dosyalarıyla aynı değil (`huseyin-emre` ve `huseyinemretech`, `KeremC23` ve `emirkerem`, `yamanmurat` ve `yamanmurat761`).
- `00-index.md`, `01-project-scope.md` ve `AGENTS.md` ekip sayısında ve çok dilli yapıda birbirini tutmuyor (#183).

### Herkesten istenen

Son tarih yoktur, ama **çalışılan her gün kaydı olur**; kayıt sonradan hatırlanarak yazılmaz.

- [ ] Çalıştığın her gün `ekip/raporlar/<klasörün>/YYYY-AA-GG.md`, o günün PR'ıyla birlikte. Şablondaki bölümler silinmez; boşsa "yok" yazılır.
- [ ] Raporda ve PR'da token: araçta görünen değer, görünmüyorsa "tahmini" notuyla.
- [ ] PR'da `Closes #` ya da `Refs #`; "Anlamadığım yer" boş bırakılmaz.
- [ ] Doküman kutusu: güncellenen dosyanın adı ya da "gerekmedi çünkü ...".
- [ ] Kişisel plan dosyanda **Raporlar** bölümüne bağlantı.
- [ ] Yeni paket ya da araç eklendiyse [teknoloji kaydı](teknoloji-degisiklikleri.md); hata çıktıysa [hata kaydı](hata-kayitlari.md); aynı PR'da.

**PR'ı inceleyen** bu listeyi de denetler; eksikse birleştirmeden önce ister. Bu denetim yeni issue ve PR'lar için tekrar edilir.

## Neden böyle yaptık

| Ne yaptık | Neden |
| --- | --- |
| Görevlere son tarih koymadık, sırayı bağımlılıkla belirledik | Vize dönemi geliyor; tarih tutmayacak bir plan yerine, kimin neyi beklediği belli bir plan daha gerçekçi |
| Son tarihi kaldırdık ama düzenli katkı ve kayıt kuralını tuttuk | Süreç GitHub geçmişinden izleniyor; toplu son gece işi kabul edilmiyor ve kayıt sonradan hatırlanarak yazılmıyor |
| Yeni özellik yerine önce bağlama işlerini öne aldık (#163, #170) | Parçaların çoğu hazır ama ürün uçtan uca çalışmıyor; kalan en büyük risk bu |
| Görevleri tek PR'lık kestik, her birine dokunulacak dosya ve test yazdık | Küçük PR kuralı; herkes yazdığını anlatabilmeli, vize döneminde de bir görev kısa sürede ele alınabilmeli |
| Mobil işleri Yusuf ve Müberra arasında böldük, Murat ve Kerem'e ayrı görev zinciri verdik | PR'lar birkaç kişide toplanmıştı; hem darboğazı azaltmak hem de katkıyı dengelemek için |
| Milestone'ları sildik yerine kapattık | Geri alınabilir ve geçmiş kaydı korunur |
| Fotoğraf yetkisini #166'da use case'e bağladık | Rule 01 kesilmez; kural tek yerde kalır, uçta yeniden yazılmaz. Bu yüzden #166, #159'u bekler |
| `11-kod-mimarisi`ni contracts kararına göre değiştirdik | Sunucuyu DTO'lara yeniden bağlamak büyük iş ve kazancı az; doküman ile kod aynı şeyi söylemeli |
| Denetimi kişi adı vermeden, ekip toplamı olarak yazdık | Amaç suçlamak değil, herkesin uyacağı ölçütü göstermek; eksikler kişilere doğrudan iletilir |
| Plan ve şablon değişikliğini iki ayrı PR yaptık (#184, #185) | `.github/` yolunun tek sahibi teknik lider ve kendi PR'ını onaylayamıyor. Şablon ayrı kalınca yönetici birleştirmesi yalnızca o tek satırlık değişiklikte gerekir, plan normal onayla ilerler |
| Onay ve birleştirmeyi teknik lidere bıraktık | Yapay zeka aracının onay ve birleştirme komutları izin denetimine takıldı; `main`'e girişte son karar insanda kalıyor |

## Yapay zeka kullanımı

| Alan | Değer |
| --- | --- |
| Araç ve model | Claude Code, Claude Opus 5.5 (`claude-opus-5-5`) |
| Skill | `superpowers:writing-plans`, `obsidian-cli`, `ponytail` (oturumda açık) |
| Ne soruldu | Projeyi incele, görevleri dağıt, plan ve issue yaz; haftaya bağlama. Sonra vault'u oku, commit et, dokümantasyonu denetle |
| Çıktıda ne değişti | Teknik lider fotoğraf yetkisi, contracts dokümanı ve haftalık kural metnindeki düzeltmeleri onayladı |
| Yapay zeka hatası | Fotoğraf erişimi ve contracts kararları ilk planda proje kurallarıyla çelişiyordu; ayrıntı: [hata kayıtları](hata-kayitlari.md) |
| Harcanan token | Doğrulanmadı (oturumda görünmedi) |
| Doğrulama | Issue'lar ve milestone'lar GitHub'dan geri okundu. Kod değişmediği için test çalıştırılmadı |

## Açık kalanlar

- #21 kapatılamadı (komut izin denetimine takıldı); teknik lider elle kapatacak, HTTPS yanıtı da o yorumla gidecek.
- Sunum tarihleri ve biçimi doğrulanmadı.
- `proje-bilgileri` Obsidian'da kayıtlı olmadığı için `unresolved`, `orphans`, `deadends` taraması bu kayıt için çalıştırılamadı.
