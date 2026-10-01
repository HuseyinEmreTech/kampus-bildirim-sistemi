# AGENTS.md: Campus Report için yapay zeka kuralları

Bu dosya, ekipteki herkesin yapay zeka aracına (Claude Code, Codex, Gemini, Copilot vb.) verilen ortak kural setidir. Araç kod yazmadan önce bunu okumalıdır.

## Proje bağlamı

- Kampüs sorun bildirim sistemi; **ders projesi**, canlı demo ve sunum için. Üretim sistemi değil.
- Ölçek: tek kampüs, en fazla birkaç yüz kullanıcı. 4 kişilik ekip, 15 haftalık dönem.
- Flutter (Android) istemci, Dart (Shelf) sunucu, PostgreSQL 16.
- **En basit çalışan çözüm.** Mikroservis, kuyruk, önbellek, ORM, kod üretimi, durum yönetimi paketi, DI paketi yok.
- Ayrıntı: `proje-bilgileri/01-project-scope.md`, `proje-bilgileri/03-domain-design.md` (kurallar Rule 00-07), `proje-bilgileri/05-api-design.md`, `proje-bilgileri/11-kod-mimarisi-ve-korumalar.md`.

## Paket kuralları (ihlal CI'ı kırar)

| Paket | Klasör | İzinli bağımlılık | Yasak |
| --- | --- | --- | --- |
| `campus_domain` | `packages/domain` | yok | `dart:io`, her dış paket |
| `campus_application` | `packages/application` | `campus_domain` | `dart:io`, veritabanı, HTTP |
| `campus_contracts` | `packages/contracts` | yok | `dart:io`, domain sınıfları |
| `campus_infrastructure` | `packages/infrastructure` | `campus_domain`, `campus_application`, onaylı dış paketler | HTTP katmanı |
| `campus_server` | `packages/server` | hepsi | iş kuralı yazmak (kural servistedir) |
| `campus_app` | `packages/app` | `campus_contracts`, onaylı Flutter paketleri | `campus_domain`, `campus_application`, iş kuralı |

## Kod kuralları

- Domain nesneleri: özel yapıcı, `create` fabrika metodu, `final` alanlar, setter yok. Durum yalnızca metotla değişir (`assign`, `resolve`).
- Domain ve servisler istisna fırlatarak akış kontrol etmez; sonuç tipi (`Result`, `sealed` hata) döner.
- Hata eşleme `switch` ifadesiyle; `default` dalı kullanma (yeni hata eklenince derleyici uyarsın).
- SQL yalnızca parametreli (`$1`, `$2`); string birleştirme ile SQL yazma.
- Sihirli sayı yok: limitler (5 MB, sayfa boyutu) adlandırılmış sabit veya yapılandırma.
- Bir metot bir iş; iç içe koşul yerine erken çıkış.
- JSON dönüşümü elle `fromJson` / `toJson`.
- `print` yok; sunucuda günlük kaydı için ortak logger.

## Çalışma biçimi

1. **Önce plan:** kod yazmadan önce ne yapacağını ve hangi dosyalara dokunacağını söyle; issue'daki "dokunulmayacak dosyalar" listesine girme.
2. **Küçük parça:** tek seferde tek davranış; test ile birlikte.
3. **Test önce:** davranış için önce başarısız test, sonra kod. `@Tags(['bekliyor'])` ile işaretli kabul testlerini **değiştirme**, yalnızca etiketi kaldırıp yeşile çevir.
4. **Yeni paket ekleme:** gerekirse dur ve sor.
5. **Sınama:** bitirmeden önce `dart format .`, `dart analyze --fatal-infos`, ilgili paketin testleri.
6. **Özet:** sonunda ne yaptığını, hangi varsayımı yaptığını ve neyi doğrulamadığını kısaca yaz; geliştirici bunu PR'a koyacak ve hocaya anlatabilecek olmalı.
7. Davranış değişirse ilgili doküman (`proje-bilgileri/`) aynı PR'da güncellenir.

## Git

- Branch: `feature/<issue-no>-<kisa-ad>`, `fix/...`, `docs/...`, `test/...`. `main`'e doğrudan commit yok.
- Commit mesajı Türkçe ve önekli: `feat:`, `fix:`, `test:`, `docs:`, `refactor:`, `chore:`.
- Sır, şifre, token, `.env`, gerçek öğrenci verisi commit'e girmez.

## Doküman kuralları

- `proje-bilgileri/` bir Obsidian vault'udur; içerik Türkçe.
- Front matter: `title`, `durum`, `son-guncelleme`; üstte `← İndeks` bağlantısı.
- Bağlantılar standart Markdown (`[metin](dosya.md)`), wikilink yok; klasöre değil dosyaya bağlantı.
- Dosya adı: sıra numarası veya tarih + kebab-case, Türkçe karakter yok.
- Doğrulanmayan bilgi "doğrulanmadı" diye yazılır; uydurma sürüm, tarih, iddia yok.
- ADR silinmez; değişirse eskisinin durumu "Yerini ADR-NN aldı" olur.
