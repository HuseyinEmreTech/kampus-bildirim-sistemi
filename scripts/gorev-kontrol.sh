#!/usr/bin/env bash
# Görev adımları kontrolü: proje-bilgileri/ekip/gorev-adimlari.md
#
# Kullanım:
#   bash scripts/gorev-kontrol.sh            # dal kontrolü (PR açmadan önce)
#   bash scripts/gorev-kontrol.sh pr [no]    # dal kontrolü + PR başlığı/açıklaması (gh gerekir)
#   bash scripts/gorev-kontrol.sh staged     # pre-commit kancası: hazırlanan değişiklik
#   bash scripts/gorev-kontrol.sh mesaj DOSYA  # commit-msg kancası: commit mesajı
#
# Yalnızca bash, git, grep, sed ve awk kullanır (Windows'ta Git Bash ile de çalışır).
# Çıkış kodu: hata varsa 1, yalnızca uyarı varsa 0.

set -u

TABAN="${GOREV_TABAN:-origin/main}"
MESAJ_RE='^(feat|fix|test|docs|refactor|chore)(\([^)]+\))?: .+'
DAL_RE='^(feature|fix|test|docs|chore)/[0-9]+-[a-z0-9-]+$'
# Kod sayılmayan yollar: bunlara dokunan dal için "önce test" aranmaz.
DOKUMAN_RE='(^proje-bilgileri/|^docs/|\.md$|^\.github/|^db/seed/|^LICENSE)'

hata=0
uyari=0
tamam() { printf '  ✓ %s\n' "$1"; }
hata() { printf '  ✗ %s\n' "$1"; hata=$((hata + 1)); }
uyar() { printf '  ! %s\n' "$1"; uyari=$((uyari + 1)); }
# Geçmişe bağlı kurallar (dal adı, commit mesajı, test sırası). GOREV_ESKI=1: PR 24 Kasım
# duyurusundan (#236) önce açıldı; geçmiş yeniden yazılmaz, bu yüzden hata değil uyarı.
gecmis() { if [ "${GOREV_ESKI:-0}" = 1 ]; then uyar "$1 (duyurudan önce açılmış PR; geçmiş yeniden yazılmaz)"; else hata "$1"; fi; }

# Commit mesajının ilk satırı commit kuralına uyuyor mu.
mesaji_denetle() {
  local ilk="$1"
  case "$ilk" in
    Merge\ *|fixup!\ *|squash!\ *) tamam "Birleştirme/düzeltme commit'i, atlandı: $ilk"; return ;;
  esac
  if printf '%s' "$ilk" | grep -Eq "$MESAJ_RE"; then
    tamam "Mesaj kurala uygun: $ilk"
  else
    gecmis "Mesaj kurala uymuyor: \"$ilk\". Biçim: <önek>: <Türkçe özet>; önekler feat, fix, test, docs, refactor, chore (AGENTS.md)"
  fi
}

# Verilen fark (git diff çıktısı) ve dosya listesi üzerinde kod kuralları.
farki_denetle() {
  local fark="$1" dosyalar="$2"

  local yasak
  yasak=$(printf '%s\n' "$dosyalar" | grep -E '(^|/)\.env$|\.pem$|\.key$|^gizli/|(^|/)CLAUDE\.local\.md$|settings\.local\.json$' || true)
  if [ -n "$yasak" ]; then
    hata "Commit'e girmemesi gereken dosya: $(printf '%s' "$yasak" | tr '\n' ' ')(sır, kişisel not ya da gizli/)"
  else
    tamam "Sır/kişisel dosya yok"
  fi

  # Yalnızca eklenen satırlar, yalnızca üretim Dart kodu (lib/, bin/).
  local kod
  kod=$(printf '%s\n' "$fark" | awk '
    /^\+\+\+ / { yol = substr($0, 7); next }
    /^\+/ && yol ~ /^packages\/[^\/]+\/(lib|bin)\/.*\.dart$/ { print yol ": " substr($0, 2) }')

  if printf '%s\n' "$kod" | grep -Eq '(^|[^A-Za-z_.])print\('; then
    hata "print kullanılmış (AGENTS.md: print yok, sunucuda ortak logger): $(printf '%s\n' "$kod" | grep -E '(^|[^A-Za-z_.])print\(' | head -1)"
  else
    tamam "print yok"
  fi
  if printf '%s\n' "$kod" | grep -Eq ':[[:space:]]*default[[:space:]]*:|^[^:]*:[[:space:]]+default[[:space:]]*:'; then
    hata "switch içinde default dalı var (AGENTS.md: default yok, derleyici yeni durumu yakalasın): $(printf '%s\n' "$kod" | grep -E 'default[[:space:]]*:' | head -1)"
  else
    tamam "default dalı yok"
  fi
  if printf '%s\n' "$kod" | grep -Eq ':[[:space:]]*_[[:space:]]*=>'; then
    uyar "switch ifadesinde joker dal (_ =>) var; default ile aynı etkide, sealed/enum için tüm durumları yaz: $(printf '%s\n' "$kod" | grep -E ':[[:space:]]*_[[:space:]]*=>' | head -1)"
  fi
  if printf '%s\n' "$kod" | grep -Eiq "(select|insert|update|delete)[^'\"]*['\"].*(\\\$\{|\\\$[a-z_]|' *\+|\" *\+)"; then
    uyar "SQL string birleştirmesi olabilir; yalnızca \$1, \$2 parametreleri (AGENTS.md): $(printf '%s\n' "$kod" | grep -Eio "(select|insert|update|delete).*" | head -1)"
  fi
  if printf '%s\n' "$fark" | grep -Eq '^\+.*-----BEGIN [A-Z ]*PRIVATE KEY-----'; then
    hata "Özel anahtar eklenmiş"
  fi
}

dart_bicim() {
  local dosyalar="$1"
  local dartlar
  dartlar=$(printf '%s\n' "$dosyalar" | grep -E '\.dart$' | while read -r f; do [ -f "$f" ] && printf '%s\n' "$f"; done)
  [ -z "$dartlar" ] && return
  if ! command -v dart >/dev/null 2>&1; then
    uyar "dart bulunamadı; biçim denetimi atlandı (dart format --output=none --set-exit-if-changed .)"
    return
  fi
  # shellcheck disable=SC2086
  if dart format --output=none --set-exit-if-changed $dartlar >/dev/null 2>&1; then
    tamam "dart format temiz"
  else
    hata "dart format gerekli: dart format $(printf '%s' "$dartlar" | tr '\n' ' ')"
  fi
}

staged_kontrol() {
  echo "Görev kontrolü (commit öncesi)"
  local dosyalar fark
  dosyalar=$(git diff --cached --name-only --diff-filter=ACMR)
  fark=$(git diff --cached -U0 --diff-filter=ACMR)
  farki_denetle "$fark" "$dosyalar"
  dart_bicim "$dosyalar"
}

dal_kontrol() {
  local dal
  dal="${GOREV_DAL:-$(git rev-parse --abbrev-ref HEAD)}"
  # Denetlenen uç: yerelde başka bir daldayken GOREV_DAL verilirse origin/<dal>.
  # CI'da HEAD ayrık (PR'ın kendisi) olduğu için HEAD kalır.
  local uc=HEAD su_an
  su_an=$(git rev-parse --abbrev-ref HEAD)
  if [ "$su_an" != HEAD ] && [ "$su_an" != "$dal" ] && git rev-parse --verify -q "origin/$dal" >/dev/null; then
    uc="origin/$dal"
  fi
  echo "Görev kontrolü: $dal ($TABAN ile karşılaştırılıyor; uç: $uc)"

  if ! git rev-parse --verify -q "$TABAN" >/dev/null; then
    hata "$TABAN bulunamadı; önce git fetch origin"
    return
  fi

  if printf '%s' "$dal" | grep -Eq "$DAL_RE"; then
    tamam "Dal adı kurala uygun (adım 4)"
  else
    gecmis "Dal adı kurala uymuyor: $dal. Biçim: feature|fix|test|docs|chore/<issue-no>-<kisa-ad> (adım 4)"
  fi

  local sayi
  sayi=$(git rev-list --count "$TABAN..$uc")
  if [ "$sayi" -eq 0 ]; then
    uyar "$TABAN'a göre yeni commit yok"
    return
  fi

  if ! git merge-base --is-ancestor "$TABAN" "$uc"; then
    uyar "Dal güncel $TABAN'ı içermiyor; PR'dan önce: git fetch origin && git rebase $TABAN"
  fi

  echo "Commit mesajları ($sayi):"
  while IFS= read -r konu; do
    mesaji_denetle "$konu"
  done < <(git log --reverse --format='%s' "$TABAN..$uc")

  local dosyalar
  dosyalar=$(git diff --name-only --diff-filter=ACMR "$TABAN...$uc")
  local kod_dosyalari
  kod_dosyalari=$(printf '%s\n' "$dosyalar" | grep -Ev "$DOKUMAN_RE" | grep -v '^$' || true)

  echo "Önce test (adım 5-6):"
  if [ -z "$kod_dosyalari" ]; then
    tamam "Yalnızca doküman/yapılandırma değişmiş; kırmızı test adımı aranmıyor"
  else
    local ilk_test ilk_kod
    ilk_test=$(git log --reverse --format='%h %s' "$TABAN..$uc" | grep -E '^[0-9a-f]+ test(\([^)]+\))?: ' | head -1)
    ilk_kod=$(git log --reverse --format='%h %s' "$TABAN..$uc" | grep -E '^[0-9a-f]+ (feat|fix|refactor)(\([^)]+\))?: ' | head -1)
    if [ -z "$ilk_test" ]; then
      gecmis "Kod değişmiş ama test: commit'i yok. Önce kabul ölçütündeki testi yaz, kırmızı gör, test: önekiyle commit et"
    elif [ -n "$ilk_kod" ] && [ "$(git log --reverse --format='%h' "$TABAN..$uc" | grep -n "^${ilk_test%% *}" | cut -d: -f1)" -gt "$(git log --reverse --format='%h' "$TABAN..$uc" | grep -n "^${ilk_kod%% *}" | cut -d: -f1)" ]; then
      gecmis "İlk test: commit'i ($ilk_test) ilk kod commit'inden ($ilk_kod) sonra geliyor; test önce yazılmalı"
    else
      tamam "Kırmızı test commit'i: $ilk_test"
      [ -n "$ilk_kod" ] && tamam "Yeşil commit: $ilk_kod"
    fi
    if printf '%s\n' "$dosyalar" | grep -Eq '(^|/)test/|_test\.dart$|/tests/|test_.*\.py$|Tests?/|[-_]test\.sh$|\.test\.js$'; then
      tamam "Test dosyası değişmiş"
    else
      hata "Kod değişmiş ama hiçbir test dosyası değişmemiş"
    fi
  fi

  echo "Günlük rapor (adım 11):"
  if printf '%s\n' "$dosyalar" | grep -Eq '^proje-bilgileri/ekip/raporlar/'; then
    tamam "Günlük rapor eklenmiş"
  else
    uyar "Bu dalda günlük rapor yok: proje-bilgileri/ekip/raporlar/<kullanıcı>/YYYY-MM-DD.md (ayrı PR'da da olabilir)"
  fi

  echo "Kod kuralları (adım 9):"
  farki_denetle "$(git diff -U0 --diff-filter=ACMR "$TABAN...$uc")" "$dosyalar"
  dart_bicim "$dosyalar"

  echo
  echo "Adım kanıtı taslağı (PR açıklamasına kopyala, eksikleri doldur):"
  echo "4. Dal: $dal"
  echo "5. Kırmızı test commit'i: $(git log --reverse --format='%h %s' "$TABAN..$uc" | grep -E '^[0-9a-f]+ test' | head -1)"
  echo "6. Yeşil commit: $(git log --reverse --format='%h %s' "$TABAN..$uc" | grep -E '^[0-9a-f]+ (feat|fix)' | head -1)"
  echo "8. git diff --stat:"
  git diff --stat "$TABAN...$uc" | tail -1
}

pr_kontrol() {
  local no="${1:-}"
  echo "PR kontrolü (adım 12-13)"
  if ! command -v gh >/dev/null 2>&1; then
    uyar "gh bulunamadı; PR denetimi atlandı"
    return
  fi
  local baslik govde
  if ! baslik=$(gh pr view ${no:+"$no"} --json title -q .title 2>/dev/null); then
    uyar "Bu dal için açık PR bulunamadı"
    return
  fi
  govde=$(gh pr view ${no:+"$no"} --json body -q .body)

  if printf '%s' "$baslik" | grep -Eq "$MESAJ_RE" && printf '%s' "$baslik" | grep -Eq '\(#[0-9]+\)$'; then
    tamam "PR başlığı kurala uygun: $baslik"
  else
    hata "PR başlığı kurala uymuyor: \"$baslik\". Biçim: <önek>: <Türkçe özet> (#<issue-no>); squash ile main'deki commit mesajı olur"
  fi
  if printf '%s' "$govde" | grep -Eiq '(closes|refs) #[0-9]+'; then
    tamam "Issue bağı var (Closes/Refs)"
  else
    hata "Açıklamada Closes #<no> ya da Refs #<no> yok"
  fi
  local alan
  for alan in "Araç ve model" "Kullanılan skill" "Çıktıda neyi değiştirdim" "Geliştirme ortamı" "Çalıştırılan araçlar" "Anlamadığım"; do
    local satir
    satir=$(printf '%s\n' "$govde" | grep -m1 -- "$alan" || true)
    if [ -z "$satir" ]; then
      hata "Yapay zeka beyanında \"$alan\" alanı yok"
    elif printf '%s' "$satir" | grep -Eq ':[[:space:]]*$'; then
      hata "Yapay zeka beyanında \"$alan\" boş"
    elif [ "$alan" != "Kullanılan skill" ] && printf '%s' "$satir" | grep -Eiq ':[[:space:]]*(yok|-)[[:space:].]*$'; then
      hata "\"$alan\" için \"yok\" yazılmış; gerçek bir müdahale ya da öğrendiğin nokta yaz (adım 13)"
    else
      tamam "\"$alan\" dolu"
    fi
  done
  if printf '%s\n' "$govde" | grep -q '^## Adım kanıtı'; then
    local bos
    # "N. Ad:" satırı, altında girintili madde yoksa boştur.
    bos=$(printf '%s\n' "$govde" | tr -d '\r' | sed -n '/^## Adım kanıtı/,/^## /p' | awk '
      bekle && /^[[:space:]]+[^[:space:]]/ { bekle = 0; next }
      { if (bekle) n++; bekle = 0 }
      /^[0-9]+\. [^:]*:[[:space:]]*$/ { bekle = 1 }
      END { if (bekle) n++; print n + 0 }')
    if [ "$bos" -gt 0 ]; then
      hata "Adım kanıtında $bos boş satır var"
    else
      tamam "Adım kanıtı dolu"
    fi
  else
    hata "PR açıklamasında \"## Adım kanıtı\" bölümü yok (PR şablonu)"
  fi
  if printf '%s' "$govde" | grep -Eq '\- \[x\] Bu koddaki her satırı hocaya anlatabilirim'; then
    tamam "\"Her satırı anlatabilirim\" işaretli"
  else
    hata "\"Bu koddaki her satırı hocaya anlatabilirim\" kutusu işaretli değil"
  fi
}

sonuc() {
  echo
  if [ "$hata" -gt 0 ]; then
    echo "Sonuç: $hata hata, $uyari uyarı. Adımlar: proje-bilgileri/ekip/gorev-adimlari.md"
    exit 1
  fi
  echo "Sonuç: hata yok, $uyari uyarı."
  exit 0
}

case "${1:-dal}" in
  staged) staged_kontrol ;;
  mesaj)
    echo "Görev kontrolü (commit mesajı)"
    mesaji_denetle "$(head -1 "${2:?commit mesajı dosyası gerekli}")"
    ;;
  pr) dal_kontrol; echo; pr_kontrol "${2:-}" ;;
  dal) dal_kontrol ;;
  *) echo "Bilinmeyen kip: $1 (dal | pr [no] | staged | mesaj DOSYA)"; exit 2 ;;
esac
sonuc
