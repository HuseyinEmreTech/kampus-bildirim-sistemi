---
name: gorev-kontrol
description: Campus Report reposunda commit atmadan, push etmeden ya da PR açmadan veya güncellemeden önce kullan. Görev adımlarının (proje-bilgileri/ekip/gorev-adimlari.md) harfiyen uygulandığını scripts/gorev-kontrol.sh ile denetler; dal adı, commit mesajı, önce test, kod kuralları, günlük rapor, PR başlığı, yapay zeka beyanı ve adım kanıtı. Tetikleyiciler: "commit", "commit at", "push", "PR aç", "PR açıklaması", "görev kontrol", "adım kanıtı", "issue'yu bitir".
---

# Görev kontrolü

Bu repoda her görev `proje-bilgileri/ekip/gorev-adimlari.md` dosyasındaki adımlarla, **harfiyen** yürür. Bu skill o adımların uygulandığını kontrol eder. Kontrolü `scripts/gorev-kontrol.sh` yapar; aynı betik git kancalarında ve CI'da (`.github/workflows/gorev-adimlari.yml`) da çalışır, yani skill'in denetlediği şey hocanın göreceği şeyle aynıdır.

## Ne zaman

- Commit atmadan önce: `bash scripts/gorev-kontrol.sh staged`
- Push etmeden ya da PR açmadan önce: `bash scripts/gorev-kontrol.sh dal`
- PR açıldıktan veya açıklaması değiştikten sonra: `bash scripts/gorev-kontrol.sh pr <PR-no>`

## Adımlar

1. **Kancalar kurulu mu?** `git config --get core.hooksPath` çıktısı `.githooks` değilse kullanıcıya söyle ve `bash scripts/hook-kur.sh` çalıştır. Kanca, her commit'te aynı kontrolü yapar.
2. **Issue'yu oku.** Çalışılan issue'yu (dal adındaki numara) `gh issue view <no>` ile aç. "Adımlar (harfiyen uygulanır)" listesinde sıradaki adım hangisiyse onu yap. Adım atlama. Bağımlılıklar birleşmediyse dur ve kullanıcıya söyle.
3. **Kontrolü çalıştır,** yukarıdaki kiplerden uygun olanıyla. Çıktıdaki her `✗` bir hatadır, her `!` bir uyarıdır.
4. **Hataları düzelt, atlatma.**
   - `--no-verify` kullanma, testi gevşetme, kuralı devre dışı bırakma.
   - Kod değişmiş ama `test:` commit'i yoksa önce testi yaz, kırmızı olduğunu göster, sonra kodu yaz.
   - Dal adı ya da geçmiş commit mesajı yanlışsa kullanıcıya söyle. Geçmişi yeniden yazmak (`rebase -i`, `push --force`) kullanıcının kararıdır.
5. **PR açıklamasını şablona göre doldur.**
   - "Adım kanıtı" bölümüne betiğin bastığı taslağı (dal, kırmızı ve yeşil commit, `git diff --stat`) ve kontrol komutlarının son satırlarını koy.
   - Yapay zeka beyanında şunlar **gerçek** değerlerle yazılır: araç ve model adı (örn. "Claude Opus 5.5"), kullanılan skill'ler, geliştirme ortamı, çalıştırılan araçlar ve sürümleri. Sürüm uydurma; bilmiyorsan komutla öğren (`flutter --version`, `dart --version`, `python --version`).
   - "Çıktıda neyi değiştirdim" ve "Anlamadığım yer" alanlarına "yok" yazma; kullanıcıya sor.
6. **Hocanın sorularını kullanıcı cevaplar.** İnceleme yorumundaki "Hocanın sorabileceği sorular" bölümünün cevabını **yazma**. Kullanıcının konuyu anlamasına yardım edebilirsin, ama PR'a giden cevap onun kendi cümlesi olmalı. Hoca sunumda koda hakimiyeti sorgulayacak.
7. **Issue'daki kutuları işaretlet.** Yapılan adımların kutusunu işaretlemesini kullanıcıya hatırlat; ya da kullanıcı izin verirse `gh issue edit` ile işaretle.
8. **Sonucu bildir.** Kaç hata ve uyarı kaldı, hangi adım sırada; tek paragraf.

## Notlar

- Betik yalnızca `bash`, `git`, `grep`, `sed` ve `awk` kullanıyor; Windows'ta Git Bash ile çalışır. `dart` yoksa biçim denetimini atlar ve uyarır.
- Betiği değiştirirsen `bash scripts/gorev-kontrol-test.sh` ile kendi testlerini çalıştır.
