---
title: Skill Kataloğu
durum: Güncel
son-guncelleme: 2026-09-30
---
l
# Skill Kataloğu

← [İndeks](../00-index.md) · Kullanım günlüğü: [Skill, Plugin ve araç kullanımı](skill-ve-arac-kullanimi.md)

Bu katalog, geliştirme ortamında kurulu olan ve projeyle ilgili Skill'leri **ne olduğu, neden var olduğu, projede neden kullanıldığı (ya da kullanılacağı)** ile anlatır. Açıklamalar Skill dosyalarının kendi tanımlarından derlenmiştir. Kullanım durumu her hafta güncellenir.

**Skill nedir?** Yapay zeka ajanına belirli bir konuda uzmanlık ve tekrar kullanılabilir çalışma talimatları kazandıran modüldür: en az bir `SKILL.md` dosyası (ad, açıklama ve gövde) ve isteğe bağlı yardımcı kaynaklar. Ajan önce açıklamaya bakıp uygun Skill'i seçer, sonra gövdeyi okur (Progressive Disclosure). Bu, dersteki Gün 11 konusudur.

**Durum etiketleri**

| Etiket | Anlam |
| --- | --- |
| **Kullanıldı** | Bu projede bilinçli olarak çağrıldı |
| **Otomatik** | Ortam tarafından her oturumda kendiliğinden yüklendi; çağırmasak da yanıtları etkiler |
| **Planlandı** | Belirli bir proje adımında kullanılacak |
| **Gerektiğinde** | Koşul oluşursa kullanılır |
| **Kullanılmadı** | Kurulu, projede çağrılmadı |

## Özet tablo

| Grup | Skill | Durum | İlk kullanım |
| --- | --- | --- | --- |
| Obsidian | `obsidian-cli` | Kullanıldı | 2026-09-25 |
| Obsidian | `obsidian-bases` | Kullanıldı | 2026-09-25 |
| Obsidian | `obsidian-markdown` | Kullanılmadı | - |
| Obsidian | `json-canvas` | Kullanılmadı | - |
| Obsidian | `defuddle` | Kullanılmadı | - |
| Superpowers | `using-superpowers` | Otomatik | 2026-09-30 |
| Superpowers | `brainstorming` | Kullanıldı | 2026-09-30 |
| Superpowers | `writing-plans` | Planlandı | - |
| Superpowers | `test-driven-development` | Planlandı | - |
| Superpowers | `verification-before-completion` | Planlandı | - |
| Superpowers | `requesting-code-review` | Planlandı | - |
| Superpowers | `receiving-code-review` | Planlandı | - |
| Superpowers | `finishing-a-development-branch` | Planlandı | - |
| Superpowers | `systematic-debugging` | Gerektiğinde | - |
| Superpowers | `using-git-worktrees` | Gerektiğinde | - |
| Superpowers | `executing-plans` | Gerektiğinde | - |
| Superpowers | `subagent-driven-development` | Kullanılmadı | - |
| Superpowers | `dispatching-parallel-agents` | Kullanılmadı | - |
| Superpowers | `writing-skills` | Planlandı | - |
| Superpowers | `diagnosing-superpowers` | Kullanılmadı | - |
| Ponytail | `ponytail` | Otomatik | 2026-09-30 |
| Ponytail | `ponytail-review`, `ponytail-audit`, `ponytail-debt`, `ponytail-gain`, `ponytail-help` | Kullanılmadı | - |
| Yerleşik | `code-review`, `security-review`, `simplify` | Planlandı | - |
| Yerleşik | `run`, `init`, `update-config` | Gerektiğinde | - |

---

## 1. Obsidian Skill'leri

Kaynak: `obsidian-skills` eklentisi (sürüm 1.0.1). Dokümantasyon vault'unu (`proje-bilgileri`) yönetmek için.

### `obsidian-cli`

| | |
| --- | --- |
| **Ne** | Çalışan bir Obsidian örneğini komut satırından yönetir: notları okuma, oluşturma, arama, özellikler, etiketler, bağlantılar; eklenti geliştirme komutları |
| **Neden var** | Notları ve vault yapısını betiklenebilir yapmak; dosya sistemine bakmakla yetinmeyip Obsidian'ın kendi bağlantı çözümlemesini kullanmak |
| **Projede neden** | Dokümantasyonun kalitesini **kanıtlı** kontrol etmek: çözülemeyen bağlantılar (`unresolved`), yetim dosyalar (`orphans`), çıkışsız dosyalar (`deadends`), özellik listesi (`properties`) |
| **Nasıl kullanıyoruz** | Her doküman eklemesinden sonra `obsidian vault=proje-bilgileri unresolved`, `orphans`, `deadends` çalıştırılır; sonuç sıfır olmalıdır |
| **Şimdiye kadar** | 30 Eylül taraması `adr/` ve `haftalik/` klasör bağlantılarını ve yetim günlük dosyasını buldu; düzeltildi ([hata kaydı](hata-kayitlari.md)) |
| **Dikkat** | Obsidian açık olmalı; yalnızca kayıtlı vault'lara erişir; komut çıktısı doğrulama aracıdır, içerik doğruluğunu göstermez |
| **Durum** | Kullanıldı |

### `obsidian-bases`

| | |
| --- | --- |
| **Ne** | `.base` dosyaları: notları özelliklerine göre filtreleyen, formül ve özet içeren tablo ve kart görünümleri |
| **Neden var** | Notlardan veritabanı benzeri görünümler kurmak |
| **Projede neden** | Kişisel ders notlarında haftalara ve konulara göre listeler için kullanıldı. Proje vault'unda henüz gerek yok; kayıtlar Markdown tablolarıyla tutuluyor |
| **Durum** | Kullanıldı (kişisel notlarda) |

### `obsidian-markdown`

| | |
| --- | --- |
| **Ne** | Obsidian'a özgü Markdown (wikilink, gömme, callout, özellikler, etiketler) yazma kuralları |
| **Neden var** | Obsidian biçimini doğru üretmek |
| **Projede neden kullanılmadı** | Proje dokümanları bilinçli olarak **standart Markdown** kullanıyor (wikilink yok), çünkü hoca GitHub'da okuyor; Obsidian'a özgü sözdizimi GitHub'da bozuk görünür |
| **Ne zaman kullanılır** | Kişisel notlarda |
| **Durum** | Kullanılmadı |

### `json-canvas`

| | |
| --- | --- |
| **Ne** | `.canvas` dosyaları (düğüm, kenar, grup) |
| **Neden var** | Obsidian'da görsel harita ve akış şeması |
| **Projede neden kullanılmadı** | Şemalar Mermaid ile yazılıyor; GitHub Mermaid'i doğrudan çiziyor, `.canvas` çizmiyor |
| **Durum** | Kullanılmadı |

### `defuddle`

| | |
| --- | --- |
| **Ne** | Web sayfasından gezinti ve reklamı ayıklayıp temiz Markdown çıkarır; token tasarrufu sağlar |
| **Neden var** | Uzun web sayfalarını bağlama daha ucuza almak |
| **Projede ne zaman** | pub.dev paket sayfaları ve resmi dokümanları okurken (paket sürümü doğrulama) |
| **Durum** | Kullanılmadı |

---

## 2. Superpowers Skill'leri

Kaynak: `superpowers` eklentisi (sürüm 6.4.1). Yapay zekayı "hemen kod yaz" davranışından çıkarıp disiplinli bir yazılım geliştirme sürecine sokar. Dersin Agentic Engineering yaklaşımıyla örtüşür: çıktı planlanır, doğrulanır, incelenir.

### `using-superpowers`

| | |
| --- | --- |
| **Ne** | Skill'lerin nasıl bulunup kullanılacağını tanımlar; ilgili bir Skill varsa yanıttan önce çağrılmasını şart koşar |
| **Neden var** | Ajanın Skill'leri atlamasını engellemek |
| **Projede** | Oturum başlangıcında ortam tarafından kendiliğinden yüklenir; yani **çağırmasak da** her oturumda etkindir |
| **Durum** | Otomatik |

### `brainstorming`

| | |
| --- | --- |
| **Ne** | Uygulamadan önce niyeti, gereksinimi ve tasarımı netleştirir. İşi üç yola ayırır: **spike** (olur mu sorusu), **bounded** (mevcut koda küçük değişiklik), **architectural** (yeni proje veya alt sistem). Uygulamadan önce onay kapısı vardır |
| **Neden var** | Yapay zekanın yanlış anlayıp yanlış şeyi hızlıca üretmesini önlemek; dersteki "önce spec" ilkesinin aracı |
| **Projede neden** | Proje fikri, kapsam ve önceliklerin tartışılması; kapsam dışı bırakılacakları belirlemek |
| **Şimdiye kadar** | 30 Eylül'de proje öncelikleri ve izleme sistemi tartışmasında kullanıldı; sonuç bir öncelik listesi oldu |
| **Dikkat** | Yeni kod eklerken ("architectural") yazılı spec ve onay ister; bu, küçük iterasyon ilkemizle uyumlu ama ağır olabilir |
| **Durum** | Kullanıldı |

### `writing-plans`

| | |
| --- | --- |
| **Ne** | Onaylanmış spec'i kod yazmadan önce, küçük ve boşluksuz görevlere bölünmüş uygulama planına çevirir |
| **Neden var** | Çok adımlı işlerde plansız kodlamayı önlemek |
| **Projede neden** | Her katman (Domain, Application, Infrastructure, Api) için küçük PR'lara bölünmüş plan |
| **Ne zaman** | Hoca onayı ve spec sonrası, ilk kod işinden önce |
| **Durum** | Planlandı |

### `test-driven-development`

| | |
| --- | --- |
| **Ne** | Önce başarısız test (Red), sonra geçen kod (Green), sonra temizlik (Refactor) |
| **Neden var** | Kodun beklentiyi karşıladığını baştan kanıtlamak; yapay zekanın "çalışıyor gibi" kod üretmesini engellemek |
| **Projede neden** | Domain kurallarının (Rule 00-07) her biri testle doğrulanmalı; hocanın istediği yüksek kapsam ve sıfır veri testi |
| **Ne zaman** | Domain ve Application katmanı kodlanırken |
| **Durum** | Planlandı |

### `verification-before-completion`

| | |
| --- | --- |
| **Ne** | "Bitti, düzeldi, geçiyor" demeden önce doğrulama komutunu çalıştırıp çıktıyı görmeyi şart koşar |
| **Neden var** | Kanıtsız başarı iddiasını önlemek |
| **Projede neden** | Her PR'da testler, analiz ve bağlantı taraması gerçekten çalıştırılıp sonucu yazılmalı; dokümanın "kalite" bölümlerinin dürüstlüğü buna bağlı |
| **Ne zaman** | Commit veya PR öncesi |
| **Durum** | Planlandı |

### `requesting-code-review` ve `receiving-code-review`

| | |
| --- | --- |
| **Ne** | Birincisi iş bitince ve birleştirmeden önce incelemeyi başlatır; ikincisi gelen inceleme yorumlarına körü körüne uymadan teknik doğrulamayla yanıt vermeyi öğretir |
| **Neden var** | İncelemeyi süreçte yapmak ve yorumları gösteriş yerine doğrulukla ele almak |
| **Projede neden** | Hocanın "her PR'da review olacak" beklentisi; yapay zekanın ürettiği kodun yine bir gözden geçirmeden geçmesi |
| **Ne zaman** | Her Pull Request |
| **Durum** | Planlandı |

### `finishing-a-development-branch`

| | |
| --- | --- |
| **Ne** | İş bitip testler geçince branch'in nasıl entegre edileceğine karar verir: birleştirme, Pull Request, olduğu gibi bırakma, silme |
| **Neden var** | Branch'i düzensiz bırakmamak |
| **Projede neden** | Feature branch akışımızın son adımı: testler geçti mi, PR açılacak mı, branch silinecek mi |
| **Durum** | Planlandı |

### `systematic-debugging`

| | |
| --- | --- |
| **Ne** | Hata çözümünden önce kök nedeni dört aşamada bulmayı şart koşar; tahmine dayalı yama yapmayı yasaklar |
| **Neden var** | Semptom yamasıyla vakit kaybetmemek |
| **Projede neden** | Hoca da hatayı ayrıntılı (log, exception, değerler) vermeyi öğretiyor |
| **Ne zaman** | Test başarısız olunca veya beklenmeyen davranışta |
| **Durum** | Gerektiğinde |

### `using-git-worktrees`

| | |
| --- | --- |
| **Ne** | Özellik işi için ana çalışma alanından yalıtılmış bir çalışma dizini sağlar |
| **Neden var** | Aynı anda birden fazla işi karıştırmadan yürütmek |
| **Projede** | Feature branch akışımız zaten branch tabanlı; worktree yalnızca aynı anda iki branch üzerinde çalışılırsa gerekir |
| **Durum** | Gerektiğinde |

### `executing-plans`, `subagent-driven-development`, `dispatching-parallel-agents`

| | |
| --- | --- |
| **Ne** | Sırasıyla planı tek başına uygulama, görevleri alt ajanlara dağıtıp her görev sonrası inceleme, birbirinden bağımsız 2+ işi paralel ajanlara verme |
| **Neden var** | Büyük işleri ölçekli ve kontrollü yürütmek |
| **Projede** | Proje küçük ve tek geliştirici; alt ajan dağıtımı gereksiz karmaşıklık ve token maliyeti getirir. `executing-plans`, planı kendimiz uygularken yeterli olabilir |
| **Durum** | `executing-plans`: Gerektiğinde; diğerleri: Kullanılmadı |

### `writing-skills`

| | |
| --- | --- |
| **Ne** | Yeni Skill yazma ve Skill'in çalıştığını dağıtmadan doğrulama kuralları (Skill'ler için TDD) |
| **Neden var** | Kaliteli, test edilmiş Skill yazmak |
| **Projede neden** | Planlanan **proje standartları Skill'ini** yazarken kullanılacak |
| **Durum** | Planlandı |

### `diagnosing-superpowers`

| | |
| --- | --- |
| **Ne** | Superpowers oturumu kötü gittiğinde nedenini inceler (tekrarlanan iş, göz ardı edilen plan, pahalı oturum) |
| **Projede** | Bir oturumun neden pahalı veya verimsiz olduğunu anlamak için gerektiğinde |
| **Durum** | Kullanılmadı |

---

## 3. Ponytail Skill'leri

Kaynak: `ponytail` eklentisi (sürüm 4.8.4). Amaç: **gereksiz karmaşıklığı ve aşırı mühendisliği önlemek**; "en az kod, en kısa yol" (YAGNI). Dersin "gereksiz karmaşıklık da teknik borçtur" uyarısıyla aynı yönde.

### `ponytail`

| | |
| --- | --- |
| **Ne** | Basit çözümü zorlar: önce "bu gerçekten gerekli mi", sonra mevcut koddan/standart kütüphaneden yararlanma, en son en az kodla yazma. Bilinçli basitleştirmeleri `ponytail:` yorumuyla işaretler |
| **Neden var** | Yapay zekanın gereksiz soyutlama ve bağımlılık üretme eğilimine karşı |
| **Projede neden** | Ölçeğimiz küçük; hocanın overkill uyarısı ve "proje bağlamı" bölümü ile uyumlu |
| **Dikkat** | Oturum kancasıyla **otomatik** "full" modda çalışıyor. Yanıtlarımı etkilediği için AI kullanım kayıtlarında belirtilir. Girdi doğrulama, güvenlik ve erişilebilirlik gibi alanlarda basitleştirme yapmaz |
| **Durum** | Otomatik |

### `ponytail-review`, `ponytail-audit`, `ponytail-debt`, `ponytail-gain`, `ponytail-help`

| Skill | Ne yapar | Projede ne zaman |
| --- | --- | --- |
| `ponytail-review` | Yalnızca aşırı mühendislik odaklı diff incelemesi; silinecekleri satır satır listeler | Kod PR'larında `code-review`'a ek olarak |
| `ponytail-audit` | Tüm repo için aşırı mühendislik denetimi | Kod bir ölçeğe ulaşınca, ara denetimde |
| `ponytail-debt` | Koddaki `ponytail:` yorumlarını borç defterine döker | Teknik borç listesi için |
| `ponytail-gain` | Ponytail'in ölçülmüş etkisini gösterir | Kullanılmayacak (genel benchmark, projeye özel değil) |
| `ponytail-help` | Komut özeti | Gerektiğinde |

Durum: Kullanılmadı.

---

## 4. Yerleşik Skill'ler

### `code-review`

| | |
| --- | --- |
| **Ne** | Diff, PR numarası veya dal için doğruluk hataları ve sadeleştirme fırsatlarını, seçilen çaba seviyesinde inceler; `--comment` ile PR'a satır içi yorum, `--fix` ile düzeltme uygulama seçenekleri var |
| **Projede neden** | Hocanın "her PR'da review" beklentisine ek bir gözden geçirme katmanı |
| **Dikkat** | İnceleme çıktısı yardımcıdır; hüküm bizde. `--comment` yorum yayınladığı için yalnızca bilinçli kullanılır |
| **Durum** | Planlandı |

### `security-review`

| | |
| --- | --- |
| **Ne** | Bekleyen değişiklikleri güvenlik açısından inceler |
| **Projede neden** | [Güvenlik kararlarımız](../06-security-and-privacy.md) (SQL Injection, dosya yükleme, yetki) kodda gerçekten uygulanmış mı |
| **Durum** | Planlandı |

### `simplify`

| | |
| --- | --- |
| **Ne** | Değişen kodu yeniden kullanım, sadeleştirme, verimlilik açısından gözden geçirip düzeltmeleri uygular (hata avlamaz) |
| **Projede neden** | Refactor adımı; "bir metot bir görev" ilkesi |
| **Durum** | Planlandı |

### `run`, `init`, `update-config`

| Skill | Ne yapar | Projede |
| --- | --- | --- |
| `run` | Projenin uygulamasını çalıştırıp değişikliğin gerçekten çalıştığını görmeye yarar | Kod oluşunca demo doğrulaması |
| `init` | `CLAUDE.md` üretir | `CLAUDE.md` elle yazıldı; gerek kalmadı |
| `update-config` | `settings.json` ile yetki, kanca ve ortam ayarları | Ayar değişimi gerekirse |

Durum: Gerektiğinde / Kullanılmadı.

---

## 5. Katalog dışı tutulanlar

Kurulu olup projeyle ilgisiz oldukları için katalogda ayrıntılandırılmayanlar: Cloudflare ailesi, tasarım ve artifact Skill'leri, belge biçimi Skill'leri (`docx`, `pdf` vb.), saldırı güvenliği Skill'leri, komut aileleri (`swarm`, `sparc`, `hive-mind` vb.). Bunlar projede **kullanılmadı** ve kullanılmış gibi gösterilmez.

## 6. Bu katalog nasıl güncellenir

- Yeni bir Skill kullanılınca: özet tabloda durum ve ilk kullanım, ilgili bölümde "Şimdiye kadar" satırı güncellenir.
- Her kullanım [kullanım günlüğüne](skill-ve-arac-kullanimi.md) haftalık olarak yazılır: hangi Skill, nerede, neden, sonuç.
- Bir Skill'in tanımı değişirse (sürüm güncellemesi), sürüm ve fark burada belirtilir.
