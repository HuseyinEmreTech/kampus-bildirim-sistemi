---
title: "Görev Adımları (harfiyen uygulanır)"
durum: Güncel
son-guncelleme: 2026-11-25
---

# Görev Adımları

← [İndeks](../00-index.md) · [Teslim planı](../planlar/2026-11-24-teslim-plani.md) · [Başlangıç rehberi](00-baslangic-rehberi.md)

Bu doküman, bir görevin issue'dan birleşmeye kadar **her adımını** yazar. 24 Kasım 2026'dan itibaren her görevde **harfiyen** uygulanır. Adım atlanmaz, sırası değiştirilmez. Bir adım uygulanamıyorsa nedeni issue'ya yazılır.

**Neden bu kadar sıkı:**
- Hoca, takım üyelerinin projeye yakın ağırlıkta katkı vermesini, gerçekçi bir commit geçmişini, anlamlı commit mesajlarını ve yapay zeka kullanımının açıkça yazılmasını istiyor. Sunumda koda ne kadar hakim olduğumuzu da sorgulayacak.
- Adımlar bunların her birinin kanıtını kendiliğinden üretiyor: önce kırmızı test commit'i, yapay zeka beyanı, inceleme yorumlarına verilen cevaplar, günlük rapor.
- 3 Kasım ile 24 Kasım arasında `main`'e hiçbir şey birleşmedi. Bu adımlar o boşluğun tekrarlanmaması için.

Her açık issue'da bu dokümana dayanan, o issue'ya özel bir **"Adımlar (harfiyen uygulanır)"** listesi vardır. Görev sahibi o listedeki her kutuyu işaretler. Ayrıca PR açıklamasındaki **"Adım kanıtı"** bölümüne her adımın kanıtını yazar: commit hash'i, komut çıktısının son satırı ya da bağlantı.

## 0. Kurulum (bir kez, herkes)

Bu adımlar **kontrol edilir**: aynı denetim her commit'te git kancasıyla, her PR'da da CI'daki "Görev adımları" işiyle çalışır.

| # | Adım | Komut | Neden |
| --- | --- | --- | --- |
| 0.1 | `main`'i güncelle | `git switch main && git pull --ff-only` | Kontrol betiği ve kancalar `main`'de |
| 0.2 | Kancaları kur | `bash scripts/hook-kur.sh` | Her commit'te kod kuralları (`pre-commit`) ve mesaj kuralı (`commit-msg`), her push'ta dal kontrolü (`pre-push`) |
| 0.3 | Kurulduğunu doğrula | `git config --get core.hooksPath` → `.githooks` | — |
| 0.4 | Yapay zeka aracına tanıt | Claude Code: `gorev-kontrol` skill'i repoda hazır (`.claude/skills/gorev-kontrol/`). Codex, Gemini, Copilot, OpenCode: AGENTS.md'nin 8. maddesi aynı komutları söylüyor | Araç commit'ten önce kontrolü kendisi çalıştırsın |
| 0.5 | Kurulumu issue'ya yaz | Kendi görev issue'na `Kancalar kuruldu: .githooks` yorumu | Lider herkesin kurduğunu görsün |

Elle çalıştırmak için:
- `bash scripts/gorev-kontrol.sh staged`: commit öncesi
- `bash scripts/gorev-kontrol.sh`: dal
- `bash scripts/gorev-kontrol.sh pr <no>`: PR başlığı, beyan ve adım kanıtı dahil
- Başka bir dalın PR'ını (ör. inceleyen olarak) `main`'deyken denetlemek: `GOREV_DAL=<dal> bash scripts/gorev-kontrol.sh pr <no>`. Betik `origin/<dal>` commit'lerini okur; önce `git fetch origin`.
- Adım kanıtında bir satırın altına girintili madde yazılabilir (`7. Kontroller:` ve altında `   - komut → sonuç`); betik bu satırı dolu sayar.

**Duyurudan önce açılmış PR'lar** (#236, 24 Kasım 15:10 UTC): CI'da dal adı, eski commit mesajları ve "önce test" sırası **uyarı** olarak gösterilir. Neden: bunları düzeltmek geçmişi yeniden yazmayı gerektiriyor; bunun yerine bu PR'larda açıklama (yapay zeka beyanı, Adım kanıtı, kutular) eksiksiz istenir. Yeni commit'ler kancadan ve kurallardan muaf değildir.

Kancalar `git commit --no-verify` ile atlanabilir, ama **atlanmaz**. CI aynı kontrolü yine yapar ve lider kırmızı "Görev adımları" ile birleştirmez.

## A. Görev sahibinin adımları

| # | Adım | Nasıl | Kanıt (PR'daki "Adım kanıtı" bölümüne) |
| --- | --- | --- | --- |
| 1 | **Issue'yu baştan sona oku** | Amaç, Kabul ölçütü, Dokunulacak, Dokunulmayacak ve Bağımlı bölümlerini oku, ayrıca issue'nun güncelleme ve yorumlarını | "Okudum" yerine kabul ölçütünü kendi cümlenle tek satırda yaz |
| 2 | **Bağımlılıkları kontrol et** | "Bağımlı" satırındaki her issue/PR kapanmış ya da birleşmiş mi, `gh issue view <no>` ile bak. Birleşmediyse başlama, issue'ya `Bekliyorum: #<no>` yaz | Bağımlılıkların durumu |
| 3 | **Başladığını yaz** | Issue'ya `Başlıyorum, tahmini bitiş: <tarih>` yorumu. Issue sana atanmış olmalı | Yorumun bağlantısı |
| 4 | **Güncel `main`'den dal aç** | `git switch main && git pull --ff-only && git switch -c <önek>/<issue-no>-<kisa-ad>`. Önek: `feature/`, `fix/`, `test/`, `docs/` | Dal adı |
| 5 | **Önce testi yaz, kırmızı olduğunu gör** | Kabul ölçütündeki test adlarını **aynen** kullan. Testi çalıştır; doğru nedenle kırmızı olduğunu gör (derleme hatası değil, beklenen davranışın yokluğu). Commit: `test: <ne sınanıyor> (#<no>)`. Doküman işinde bu adım "iskeleti yaz", commit önekiyse `docs:` | Kırmızı test commit'inin hash'i ve çıktının son satırı |
| 6 | **En küçük kodu yaz, testi yeşile çevir** | Yalnızca testin istediği kadar kod. `@Tags(['bekliyor'])` ile işaretli kabul testlerinin içeriği **değiştirilmez**, yalnızca etiketi kaldırılır. Commit: `feat:` ya da `fix:` | Yeşil commit'in hash'i |
| 7 | **Yerel kontrolleri çalıştır** | Aşağıdaki "Kontrol komutları" tablosundan, dokunduğun her paketin satırı | Her komutun son satırı (ör. `All tests passed!`, `No issues found!`) |
| 8 | **Dokunulacak dosyalar listesine uy** | `git diff --stat origin/main` çıktısını issue'daki "Dokunulacak" listesiyle karşılaştır. Listede olmayan bir dosyaya dokunmak zorundaysan gerekçesini PR'a yaz | `git diff --stat` çıktısı |
| 9 | **Kod kurallarına göre kendini incele** | Aşağıdaki "Kod kuralları öz-kontrolü" listesi | Listenin işaretlenmiş hali |
| 10 | **Davranış değiştiyse dokümanı güncelle** | `proje-bilgileri/` içindeki ilgili doküman aynı dalda güncellenir. Front matter `son-guncelleme` alanı da | Güncellenen dosya ya da "gerekmedi çünkü …" |
| 11 | **Günlük raporunu yaz** | `proje-bilgileri/ekip/raporlar/<kullanıcı-adı>/YYYY-MM-DD.md` ([şablon](../Templates/gunluk-rapor.md)). Kişi dosyandaki `## Raporlar` listesine bir satır ekle | Rapor dosyasının yolu |
| 12 | **PR'ı aç** | Başlık: `<önek>: <Türkçe kısa özet> (#<issue-no>)`. Repo squash-only olduğu için **başlık `main`'deki commit mesajı olur**; dal adı başlık olmaz. İş bitiyorsa `Closes #<no>`, bitmiyorsa `Refs #<no>`. Şablonun her alanını doldur | PR bağlantısı |
| 13 | **Yapay zeka beyanını eksiksiz yaz** | Şablondaki "Yapay zeka kullanımı" alanlarının hepsi dolar: araç ve model adı (örn. "Claude Opus 5.5", yalnızca "Claude" yazmak yetmez), neden o araç, skill'ler, ne sorduğun, **çıktıda neyi değiştirdiğin**, token, emin olmadığın yer, **geliştirme ortamı** ve **çalıştırılan araçlar ile sürümleri**. "Neyi değiştirdim: yok" ve "Anlamadığım yer: yok" yazılmaz; gerçek bir müdahaleyi ya da öğrendiğin bir noktayı yaz | Şablonun dolu hali |
| 14 | **CI ve Sonar'ın yeşil olmasını bekle** | `gh pr checks <PR>`. Kırmızıysa nedenini bul, düzelt ya da PR'a yaz | Kontrol sonuçları |
| 15 | **İnceleme yorumlarının her maddesine cevap ver** | Her madde için `Yapıldı: <commit>` ya da `Yapılmadı, çünkü …` yaz. Yorumdaki **"Hocanın sorabileceği sorular"** bölümünü **kendi cümlenle** PR'a yorum olarak cevapla; yapay zekaya yazdırma, sunumda sana bunlar sorulacak | Cevap yorumunun bağlantısı |
| 16 | **Issue'daki adım listesini işaretle** | Issue'daki "Adımlar" listesinde yaptığın her kutuyu işaretle | Issue'nun bağlantısı |
| 17 | **Birleşmeden sonra kapat** | Dal silinir (lider `--delete-branch` ile birleştirir). Issue'ya tek satırlık özet yaz. `Refs` ile bağlanan iş devam ediyorsa issue açık kalır | Özet yorumu |

**Haftalık ritim:** Her üyenin her hafta **Pazar 23:59'a kadar en az bir PR'ı birleşmiş** olur. Bu yüzden PR'ı geç Cuma'ya kadar aç, inceleme ve düzeltme için iki gün kalsın. Neden: squash yüzünden `main`'deki commit sayısı birleşen PR sayısına eşit ve hoca geçmişe bakıyor.

### Kontrol komutları

| Dokunduğun yer | Komut | Geçti sayılması için |
| --- | --- | --- |
| Herhangi bir Dart paketi | `dart format --output=none --set-exit-if-changed .` | Çıkış kodu 0 |
| Herhangi bir Dart paketi | `dart analyze --fatal-infos` | `No issues found!` |
| `packages/<paket>` | `cd packages/<paket> && dart test` | `All tests passed!` |
| Veritabanına dokunan test | `dart test -t db` (PostgreSQL açıkken; CI ortam değişkenleri `.github/workflows/ci.yml` içinde) | `All tests passed!` |
| `packages/app` | `cd packages/app && flutter analyze --fatal-infos && flutter test` | İkisi de temiz |
| Mimari | `dart test test/architecture_test.dart` | `All tests passed!` |
| `web/` | `web/tests/index.html` dosyasını tarayıcıda aç | Sayfada bütün testler "pass" |
| `services/python-report-service` | `pytest -q` | `N passed` |
| `services/rapor-istatistik` | `dotnet test` | `Passed!` |
| `test/e2e` | Sunucu ve PostgreSQL açıkken `E2E_ZORUNLU=1 pytest test/e2e -v` | Atlanan test yok, hepsi `PASSED` |
| `proje-bilgileri/` | Front matter (`title`, `durum`, `son-guncelleme`), üstte `← İndeks`, wikilink yok, bağlantılar dosyaya | Elle kontrol |

### Kod kuralları öz-kontrolü

[AGENTS.md](../../AGENTS.md)'den alındı; PR'da işaretlenmiş olarak yer alır.

- [ ] Paket sınırına uydum: domain, application ve contracts `dart:io` içermez; app domain ve application paketlerine bağımlı değil.
- [ ] `switch` içinde `default` dalı yok.
- [ ] Akış istisnayla yönetilmiyor; `Result` ya da sealed hata dönüyor.
- [ ] SQL yalnızca parametreli (`$1`, `$2`); string birleştirme yok.
- [ ] Sihirli sayı yok; sınırlar adlandırılmış sabit.
- [ ] `print` yok; sunucuda ortak logger kullanılıyor.
- [ ] JSON dönüşümü elle `fromJson`/`toJson` ile.
- [ ] Yeni dış paket yok. Varsa planda adı geçiyor ve `kayitlar/teknoloji-degisiklikleri.md`'ye yazıldı.
- [ ] Sır, şifre, token ve gerçek kişi verisi yok.
- [ ] Testlerin adı ne diyorsa onu sınıyor: kodu bozunca test kırılıyor.

## B. İnceleyenin (lider) adımları

| # | Adım | Nasıl |
| --- | --- | --- |
| 1 | **Önce şablonu ve adım kanıtını kontrol et** | Şablon ya da "Adım kanıtı" eksikse inceleme yapılmaz; `Eksik: adım <N>` yorumu yazılır |
| 2 | **Kodu bağlamıyla oku** | Yalnızca diff'i değil, çağıranları ve testleri de oku |
| 3 | **Testleri yerelde koş** | Kontrol komutları tablosundaki komutlarla. Şüpheli bir testte kodu bozup testin kırıldığını gör |
| 4 | **Yorumu yaz** | Karar, birleşmeden önce yapılacaklar (her biri "neden önemli" ile), iyi olur, hocanın sorabileceği sorular (cevapsız; yazar cevaplar), yapay zeka ve araç beyanı |
| 5 | **Onayla ve birleştir** | `scripts/pr-birlesme-kontrolu.sh <PR>` → squash. Squash başlığı commit kuralına uymalı, yanlış issue bağı düzeltilmeli. `--delete-branch` |
| 6 | **Kaydet** | Haftalık kayda (`haftalik/`) ve birleşme günlüğüne bir satır |

## C. Kısaltılmış örnek: PR'daki "Adım kanıtı"

```markdown
## Adım kanıtı
1. Kabul ölçütü: başka öğrencinin bildirimi 404 döner, görevli hepsini görür.
2. Bağımlılık: #165 birleşti (24310ce).
3. https://github.com/.../issues/159#issuecomment-…
4. feature/159-detay-ucu
5. Kırmızı: a1b2c3d, "Expected: <200> Actual: <404>"
6. Yeşil: d4e5f6a
7. dart analyze: No issues found! · server: All tests passed! (154)
8. git diff --stat: 6 dosya, hepsi "Dokunulacak" listesinde
9. Öz-kontrol listesi işaretli (aşağıda)
10. 05-api-design.md güncellendi
11. proje-bilgileri/ekip/raporlar/cagdas3307/2026-11-24.md
13. Yapay zeka beyanı: yukarıda, eksiksiz
```
