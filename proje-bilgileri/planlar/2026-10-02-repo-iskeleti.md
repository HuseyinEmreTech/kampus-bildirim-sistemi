---
title: "Uygulama Planı: Repo İskeleti ve Korumalar"
durum: Onay bekliyor
son-guncelleme: 2026-10-02
---

# Repo İskeleti ve Korumalar: Uygulama Planı

← [İndeks](../00-index.md) · [Plan: Hüseyin Emre](../ekip/huseyin-emre.md)

> **Yapay zeka ile uygulayanlar için:** Bu planı görev görev uygula (`superpowers:executing-plans` veya `superpowers:subagent-driven-development`). Adımlar `- [ ]` ile işaretlidir.

**Hedef:** Ekip hafta 4'te kod yazmaya başladığında mimariyi bozan, testi kıran veya biçimsiz kodun `main`'e giremediği bir repo.

**Mimari:** Dart pub workspace içinde 5 Dart paketi ve 1 Flutter paketi. Katman kuralları üç yerde zorlanır: paket bağımlılıkları (derleme), mimari test (import taraması) ve CI (her PR'da). GitHub tarafında `CODEOWNERS`, PR ve issue şablonları.

**Teknoloji:** Dart 3.13.0, Flutter 3.47.0 (stable), `test`, `yaml`, `lints` paketleri, GitHub Actions (`actions/checkout@v4`, `subosito/flutter-action@v2`).

**Spec:** [Kod mimarisi ve korumalar](../11-kod-mimarisi-ve-korumalar.md), [Ekip ve yol haritası](../10-ekip-ve-yol-haritasi.md).

**Doğrulama:** Görev 1-3'teki komutlar 2 Ekim 2026'da yerelde (Dart 3.13.0, Flutter 3.47.0) geçici bir klasörde denendi: workspace çözüldü, `dart analyze --fatal-infos` "No issues found!", mimari test 13 test geçti; bilerek eklenen `domain → application` import'u ve `application` içinde `dart:io` testi kırdı. CI dosyası (Görev 4) GitHub'da henüz çalıştırılmadı.

## Genel kısıtlar

- Dart SDK kısıtı her pakette: `sdk: ^3.13.0`. Flutter sürümü CI'da `3.47.0`.
- Paket adları: `campus_domain`, `campus_application`, `campus_contracts`, `campus_infrastructure`, `campus_server`, `campus_app`; klasörler `packages/<ad>`.
- Her alt paketin `pubspec.yaml`'ında `resolution: workspace` ve `publish_to: none`.
- Bağımlılık sürümleri elle yazılmaz; `dart pub add` ile eklenir (pub.dev'deki güncel uyumlu sürümü seçer).
- `domain` ve `contracts` hiçbir pakete bağlanmaz; `domain`, `application`, `contracts` içinde `dart:io` yok.
- Commit mesajı Türkçe ve önekli; iş `main`'den açılan `chore/repo-iskeleti` branch'inde, tek PR.

## İnceleme odağı

Testlerin doğrudan kapsamadığı, en çok can yakacak durumlar:

1. **Yeni paket klasörü eklenmesi** (ör. biri `packages/utils` açar): mimari test "kurallar tüm paketleri kapsar" testiyle kırılmalı. Görev 3'te var.
2. **`export` ile kaçak bağımlılık** (`export 'package:campus_application/...'` domain içinde): import gibi yakalanmalı; Görev 3 regex'i `import|export` ikisini de tarar ve ihlal adımı bunu dener.
3. **Testi olmayan paket**: `dart test` test dosyası yoksa 79 koduyla çıkar ve CI'ı haksız yere kırar; CI döngüsü test klasörü boş paketi atlar (Görev 4).
4. **Biçimsiz ama doğru kod**: CI `dart format --set-exit-if-changed` ile kırılır; geliştiricinin yerelde `dart format .` çalıştırması rehberde yazıyor.
5. **CI dosyasının kendisinin değiştirilmesi** (biri kontrolü kaldırır): `CODEOWNERS` `.github/` için Hüseyin Emre onayı ister (Görev 5).

---

### Görev 1: Workspace ve paketler

**Dosyalar:**
- Oluştur: `pubspec.yaml`, `packages/{domain,application,contracts,infrastructure,server}/pubspec.yaml`, `packages/<ad>/lib/campus_<ad>.dart`
- Oluştur (araçla): `packages/app/` (`flutter create`)
- Değiştir: yok (`.gitignore` zaten `build/`, `.dart_tool/`, `*.iml` içeriyor)

**Arayüzler:**
- Üretir: paket adları `campus_domain`, `campus_application`, `campus_contracts`, `campus_infrastructure`, `campus_server`, `campus_app`. Sonraki tüm görevler bu adları kullanır.

- [ ] **Adım 1: Branch aç**

```bash
git switch main && git pull
git switch -c chore/repo-iskeleti
```

- [ ] **Adım 2: Kök `pubspec.yaml`**

```yaml
name: campus_report_workspace
publish_to: none
environment:
  sdk: ^3.13.0
workspace:
  - packages/domain
  - packages/application
  - packages/contracts
  - packages/infrastructure
  - packages/server
  - packages/app
```

- [ ] **Adım 3: Beş Dart paketi**

```bash
for p in domain application contracts infrastructure server; do
  mkdir -p packages/$p/lib packages/$p/test
  printf 'name: campus_%s\npublish_to: none\nresolution: workspace\nenvironment:\n  sdk: ^3.13.0\n' $p > packages/$p/pubspec.yaml
  printf 'library;\n' > packages/$p/lib/campus_$p.dart
done
```

- [ ] **Adım 4: Bağımlılık yönleri**

`packages/application/pubspec.yaml` sonuna:

```yaml
dependencies:
  campus_domain: any
```

`packages/infrastructure/pubspec.yaml` sonuna:

```yaml
dependencies:
  campus_domain: any
  campus_application: any
```

`packages/server/pubspec.yaml` sonuna:

```yaml
dependencies:
  campus_domain: any
  campus_application: any
  campus_infrastructure: any
  campus_contracts: any
```

(Workspace içindeki paketler `any` ile bağlanır; pub onları workspace'ten çözer.)

- [ ] **Adım 5: Flutter uygulaması**

```bash
cd packages
flutter create --project-name campus_app --org edu.iste.campusreport --platforms android app
cd ..
sed -i 's/^environment:/resolution: workspace\nenvironment:/' packages/app/pubspec.yaml
```

`packages/app/pubspec.yaml` içinde `dependencies:` altına ekle:

```yaml
  campus_contracts: any
```

- [ ] **Adım 6: Ortak geliştirme bağımlılıkları ve çözümleme**

```bash
dart pub add --dev test yaml lints
for p in domain application contracts infrastructure server; do (cd packages/$p && dart pub add --dev test); done
flutter pub get
```

Beklenen: hata yok; kökte tek `pubspec.lock`, `packages/app/pubspec.lock` silinmiş ("Deleting old lock-file" mesajı normaldir).

- [ ] **Adım 7: Commit**

```bash
git add pubspec.yaml pubspec.lock packages/
git status --short | grep -E 'build/|\.dart_tool|\.iml' && echo "HATA: üretilen dosya eklendi" || true
git commit -m "chore: Dart workspace ve altı paket"
```

---

### Görev 2: Ortak analiz kuralları

**Dosyalar:**
- Oluştur: `analysis_options.yaml`
- Değiştir: yok (`packages/app/analysis_options.yaml` Flutter'ın ürettiği `flutter_lints` ile kalır)

- [ ] **Adım 1: `analysis_options.yaml`**

```yaml
include: package:lints/recommended.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

linter:
  rules:
    - always_declare_return_types
    - avoid_print
    - prefer_final_locals
    - prefer_single_quotes
    - unawaited_futures
```

- [ ] **Adım 2: Biçim ve analiz**

```bash
dart format .
dart analyze --fatal-infos
```

Beklenen: `No issues found!`

- [ ] **Adım 3: Commit**

```bash
git add analysis_options.yaml packages/
git commit -m "chore: ortak analiz kuralları"
```

---

### Görev 3: Mimari test

**Dosyalar:**
- Oluştur: `test/architecture_test.dart`

**Arayüzler:**
- Üretir: `izinliProjeBagimliliklari` tablosu; yeni paket eklenirse önce bu tablo güncellenir (CODEOWNERS ile korunur).

- [ ] **Adım 1: Testi yaz**

```dart
// Mimari koruma testi: paketlerin birbirine bağımlılığını ve yasak import'ları denetler.
// Kurallar: proje-bilgileri/11-kod-mimarisi-ve-korumalar.md, bölüm 2.
import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

/// Paket klasörü -> o paketin bağlanabileceği proje paketleri.
const izinliProjeBagimliliklari = <String, Set<String>>{
  'domain': {},
  'contracts': {},
  'application': {'campus_domain'},
  'infrastructure': {'campus_domain', 'campus_application'},
  'server': {
    'campus_domain',
    'campus_application',
    'campus_infrastructure',
    'campus_contracts',
  },
  'app': {'campus_contracts'},
};

/// Hiçbir dış pakete bağlanamayan paketler (yalnızca Dart çekirdeği).
const disPaketYasak = {'domain', 'contracts'};

/// `dart:io` kullanamayan paketler.
const dartIoYasak = {'domain', 'application', 'contracts'};

final _paketImport = RegExp(
  r'''^\s*(?:import|export)\s+['"]package:(\w+)/''',
  multiLine: true,
);
final _dartIoImport = RegExp(
  r'''^\s*(?:import|export)\s+['"]dart:io['"]''',
  multiLine: true,
);

Map<String, dynamic> _pubspec(String klasor) => Map<String, dynamic>.from(
  loadYaml(File('packages/$klasor/pubspec.yaml').readAsStringSync()) as Map,
);

Iterable<File> _dartDosyalari(String klasor) {
  final lib = Directory('packages/$klasor/lib');
  if (!lib.existsSync()) return const [];
  return lib
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));
}

void main() {
  test('kurallar_tumPaketleriKapsar', () {
    final klasorler = Directory('packages')
        .listSync()
        .whereType<Directory>()
        .map((d) => d.uri.pathSegments[d.uri.pathSegments.length - 2])
        .toSet();
    expect(klasorler, izinliProjeBagimliliklari.keys.toSet());
  });

  for (final klasor in izinliProjeBagimliliklari.keys) {
    final kendiAdi = 'campus_$klasor';
    final izinli = izinliProjeBagimliliklari[klasor]!;

    test('${klasor}_pubspecBagimliliklari_izinliOlmali', () {
      final bagimliliklar =
          ((_pubspec(klasor)['dependencies'] as Map?) ?? const {}).keys
              .cast<String>()
              .toSet();
      final proje = bagimliliklar.where((b) => b.startsWith('campus_')).toSet();
      expect(
        proje.difference(izinli),
        isEmpty,
        reason: '$klasor izinsiz proje paketine bağlı',
      );
      if (disPaketYasak.contains(klasor)) {
        expect(
          bagimliliklar,
          isEmpty,
          reason: '$klasor hiçbir pakete bağlanamaz',
        );
      }
    });

    test('${klasor}_importlari_izinliOlmali', () {
      for (final dosya in _dartDosyalari(klasor)) {
        final icerik = dosya.readAsStringSync();
        for (final eslesme in _paketImport.allMatches(icerik)) {
          final paket = eslesme.group(1)!;
          if (paket == kendiAdi || !paket.startsWith('campus_')) continue;
          expect(
            izinli,
            contains(paket),
            reason: '${dosya.path} izinsiz import: $paket',
          );
        }
        if (dartIoYasak.contains(klasor)) {
          expect(
            _dartIoImport.hasMatch(icerik),
            isFalse,
            reason: '${dosya.path} dart:io kullanamaz',
          );
        }
      }
    });
  }
}
```

- [ ] **Adım 2: Geçtiğini gör**

Run: `dart test test/architecture_test.dart`
Beklenen: `All tests passed!` (13 test)

- [ ] **Adım 3: İhlali yakaladığını gör (sonra geri al)**

```bash
printf "export 'package:campus_application/campus_application.dart';\n" > packages/domain/lib/kotu.dart
dart test test/architecture_test.dart   # Beklenen: FAIL, "izinsiz import: campus_application"
rm packages/domain/lib/kotu.dart

printf "import 'dart:io';\n" > packages/application/lib/kotu.dart
dart test test/architecture_test.dart   # Beklenen: FAIL, "dart:io kullanamaz"
rm packages/application/lib/kotu.dart

mkdir -p packages/utils && dart test test/architecture_test.dart   # Beklenen: FAIL, kurallar_tumPaketleriKapsar
rmdir packages/utils
```

- [ ] **Adım 4: Biçim, analiz, commit**

```bash
dart format . && dart analyze --fatal-infos
git add test/architecture_test.dart
git commit -m "test: paket bağımlılıklarını denetleyen mimari test"
```

---

### Görev 4: CI

**Dosyalar:**
- Oluştur: `.github/workflows/ci.yml`

**Arayüzler:**
- Üretir: GitHub'da `kontrol` adlı kontrol; Görev 6'da `main` koruması bunu zorunlu yapar.

- [ ] **Adım 1: İş akışı**

```yaml
name: CI

on:
  pull_request:
  push:
    branches: [main]

jobs:
  kontrol:
    name: kontrol
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version: 3.47.0
          cache: true
      - name: Bağımlılıklar
        run: flutter pub get
      - name: Biçim
        run: dart format --output=none --set-exit-if-changed .
      - name: Analiz
        run: dart analyze --fatal-infos
      - name: Mimari test
        run: dart test test/architecture_test.dart
      - name: Dart paket testleri
        run: |
          for d in packages/domain packages/application packages/contracts packages/infrastructure packages/server; do
            if find "$d/test" -name '*_test.dart' 2>/dev/null | grep -q .; then
              (cd "$d" && dart test -x bekliyor -x db)
            else
              echo "$d: test dosyası yok, atlandı"
            fi
          done
      - name: Flutter testleri
        working-directory: packages/app
        run: flutter test
```

- [ ] **Adım 2: Yerelde aynı adımları çalıştır**

```bash
dart format --output=none --set-exit-if-changed . && dart analyze --fatal-infos && dart test test/architecture_test.dart && (cd packages/app && flutter test)
```

Beklenen: hepsi başarılı.

- [ ] **Adım 3: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: biçim, analiz, mimari test ve testler"
```

---

### Görev 5: CODEOWNERS, PR ve issue şablonları

**Dosyalar:**
- Oluştur: `.github/CODEOWNERS`, `.github/pull_request_template.md`, `.github/ISSUE_TEMPLATE/gorev.yml`, `.github/ISSUE_TEMPLATE/config.yml`

- [ ] **Adım 1: `.github/CODEOWNERS`**

```text
# Bu yollar değişirse Hüseyin Emre'nin onayı zorunludur (main koruması: require_code_owner_reviews).
/packages/domain/        @HuseyinEmreTech
/packages/application/   @HuseyinEmreTech
/packages/contracts/     @HuseyinEmreTech
/test/                   @HuseyinEmreTech
/.github/                @HuseyinEmreTech
/AGENTS.md               @HuseyinEmreTech
/CLAUDE.md               @HuseyinEmreTech
/analysis_options.yaml   @HuseyinEmreTech
/pubspec.yaml            @HuseyinEmreTech
```

- [ ] **Adım 2: `.github/pull_request_template.md`**

```markdown
## Ne yaptım

Closes #

<!-- 2-3 cümle: hangi davranış eklendi veya değişti -->

## Nasıl test ettim

- [ ] `dart format .` ve `dart analyze --fatal-infos` temiz
- [ ] İlgili testler yazıldı / `bekliyor` etiketi kaldırıldı ve geçiyor
- [ ] Uygulamada elle denedim (ekran işiyse ekran görüntüsü ekle)

## Yapay zeka kullanımı

- Araç ve model:
- Ne sordum (kısa):
- Çıktıda neyi değiştirdim / reddettim:
- Anlamadığım veya emin olmadığım yer (boş bırakma; yoksa "yok" yaz):

## Doküman

- [ ] İlgili doküman güncellendi: <!-- dosya adı --> / gerekmedi çünkü:

## Kontrol

- [ ] Yalnızca issue'daki dosyalara dokundum
- [ ] Sır, şifre, gerçek kişi verisi yok
- [ ] Bu koddaki her satırı hocaya anlatabilirim
```

- [ ] **Adım 3: `.github/ISSUE_TEMPLATE/gorev.yml`**

```yaml
name: Görev
description: Bir kişiye atanacak, tek PR'lık iş
title: "[Hafta NN] "
body:
  - type: textarea
    id: amac
    attributes:
      label: Amaç
      description: Bu görev bitince ne çalışıyor olacak?
    validations:
      required: true
  - type: textarea
    id: kabul
    attributes:
      label: Kabul ölçütü
      description: "Verilen / olduğunda / o zaman; bağlı kabul testleri"
    validations:
      required: true
  - type: textarea
    id: dosyalar
    attributes:
      label: Dokunulacak dosyalar
    validations:
      required: true
  - type: textarea
    id: dokunma
    attributes:
      label: Dokunulmayacak dosyalar
      value: "packages/domain, packages/application, packages/contracts, test/, .github/ (issue'da aksi yazmıyorsa)"
    validations:
      required: true
  - type: textarea
    id: kaynak
    attributes:
      label: Okunacaklar
      description: İlgili doküman, kural (Rule NN), hikaye (USR NN)
```

- [ ] **Adım 4: `.github/ISSUE_TEMPLATE/config.yml`**

```yaml
blank_issues_enabled: true
```

- [ ] **Adım 5: Commit ve PR**

```bash
git add .github/
git commit -m "chore: CODEOWNERS, PR ve görev şablonları"
git push -u origin chore/repo-iskeleti
gh pr create --title "chore: repo iskeleti ve korumalar" --body-file .github/pull_request_template.md
```

PR'da CI'ın `kontrol` adımı yeşil olmalı. Yeşilse birleştir.

---

### Görev 6: GitHub düzeni (PR birleştikten sonra)

Bu görev repoda dosya değiştirmez; GitHub ayarıdır. Komutlar `gh` ile.

- [ ] **Adım 1: CI'ı zorunlu kontrol yap**

Mevcut koruma ayarları korunarak kontrol eklenir (koruma 2 Ekim'de `required_status_checks: null` ile kuruldu; bu yüzden tüm koruma yeniden yazılır):

```bash
cat > /tmp/koruma.json <<'EOF'
{
  "required_status_checks": { "strict": true, "contexts": ["kontrol"] },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true
  },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true
}
EOF
gh api -X PUT repos/HuseyinEmreTech/kampus-bildirim-sistemi/branches/main/protection --input /tmp/koruma.json
```

Beklenen: CI kırmızıyken PR'da birleştirme düğmesi kapalı. Ekip davetleri kabul edince `enforce_admins` `true` yapılır (lider de kuralı atlayamaz).

- [ ] **Adım 2: Etiketler**

```bash
R=HuseyinEmreTech/kampus-bildirim-sistemi
for e in domain application contracts infrastructure server app docs ci; do gh label create "$e" -R $R -c 1d76db -f; done
for e in feat fix test; do gh label create "$e" -R $R -c 0e8a16 -f; done
gh label create sart -R $R -c b60205 -d "Şart: kesilmez" -f
gh label create olmali -R $R -c fbca04 -d "Olmalı" -f
gh label create olursa -R $R -c c5def5 -d "Olursa: ilk kesilecek" -f
gh label create bekliyor -R $R -c 5319e7 -d "Kabul testi hazır, uygulanmayı bekliyor" -f
```

- [ ] **Adım 3: Haftalık milestone'lar (3-15, bitiş Pazar)**

```bash
R=HuseyinEmreTech/kampus-bildirim-sistemi
while read n bitis; do
  gh api repos/$R/milestones -f title="Hafta $n" -f due_on="${bitis}T20:59:00Z" >/dev/null
done <<'EOF'
03 2026-10-04
04 2026-10-11
05 2026-10-18
06 2026-10-25
07 2026-11-01
08 2026-11-08
09 2026-11-15
10 2026-11-22
11 2026-11-29
12 2026-12-06
13 2026-12-13
14 2026-12-20
15 2026-12-27
EOF
```

(`20:59 UTC` = `23:59` Türkiye saati.)

- [ ] **Adım 4: Proje panosu**

```bash
gh project create --owner HuseyinEmreTech --title "Campus Report"
```

Panoda "Status" alanına `Yapılacak`, `Yapılıyor`, `İncelemede`, `Bitti` seçeneklerini web arayüzünden ekle; repo'yu panoya bağla (Project → Settings → Manage access ve Workflows → "Item closed → Bitti").

- [ ] **Adım 5: Hafta 3-4 issue'ları**

Her kişinin [plan dosyasındaki](../ekip/huseyin-emre.md) hafta 3 ve 4 maddeleri birer issue olarak `gorev.yml` şablonuyla açılır, kişiye atanır, milestone ve etiket verilir. Hafta 5 ve sonrası her Pazartesi açılır (kabul testleri o hafta hazır olur).
