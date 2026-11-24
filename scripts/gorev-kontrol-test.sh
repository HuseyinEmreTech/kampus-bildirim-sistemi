#!/usr/bin/env bash
# scripts/gorev-kontrol.sh için kendi kendini sınama: geçici bir depoda senaryolar kurar
# ve beklenen çıkış kodunu kontrol eder. Çalıştırma: bash scripts/gorev-kontrol-test.sh
set -u
BETIK="$(cd "$(dirname "$0")" && pwd)/gorev-kontrol.sh"
gecen=0
kalan=0

bekle() { # bekle <ad> <beklenen-kod> <komut...>
  local ad="$1" beklenen="$2"; shift 2
  local cikti kod
  cikti=$("$@" 2>&1); kod=$?
  if [ "$kod" -eq "$beklenen" ]; then
    gecen=$((gecen + 1)); printf 'PASS %s\n' "$ad"
  else
    kalan=$((kalan + 1)); printf 'FAIL %s (beklenen %s, gelen %s)\n%s\n' "$ad" "$beklenen" "$kod" "$cikti"
  fi
}

depo() { # temiz bir depo: main ve onu gösteren origin/main
  local d; d=$(mktemp -d)
  git -C "$d" init -q -b main
  git -C "$d" config user.email test@ornek.edu; git -C "$d" config user.name test
  mkdir -p "$d/packages/server/lib" "$d/packages/server/test"
  echo "void main() {}" > "$d/packages/server/lib/a.dart"
  git -C "$d" add -A; git -C "$d" commit -qm "chore: başlangıç"
  git -C "$d" update-ref refs/remotes/origin/main HEAD
  printf '%s' "$d"
}

ekle() { # ekle <depo> <dosya> <içerik> <mesaj>
  mkdir -p "$(dirname "$1/$2")"; printf '%s\n' "$3" > "$1/$2"
  git -C "$1" add -A; git -C "$1" commit -qm "$4" --no-verify
}

calistir() { (cd "$1" && shift && bash "$BETIK" "$@"); }

# 1. Doğru akış: test önce, sonra feat, kurala uygun dal ve mesajlar.
d=$(depo); git -C "$d" switch -qc feature/12-ornek
ekle "$d" packages/server/test/a_test.dart "// test" "test: örnek davranış sınanıyor (#12)"
ekle "$d" packages/server/lib/a.dart "int f() => 1;" "feat: örnek davranış (#12)"
bekle "dogru_akis_gecer" 0 calistir "$d" dal

# 2. Test commit'i yoksa hata.
d=$(depo); git -C "$d" switch -qc feature/12-ornek
ekle "$d" packages/server/lib/a.dart "int f() => 1;" "feat: örnek davranış (#12)"
bekle "test_commiti_yoksa_kalir" 1 calistir "$d" dal

# 3. Test, kod commit'inden sonra geliyorsa hata.
d=$(depo); git -C "$d" switch -qc feature/12-ornek
ekle "$d" packages/server/lib/a.dart "int f() => 1;" "feat: örnek davranış (#12)"
ekle "$d" packages/server/test/a_test.dart "// test" "test: örnek davranış sınanıyor (#12)"
bekle "test_sonra_gelirse_kalir" 1 calistir "$d" dal

# 4. Kurala uymayan dal adı.
d=$(depo); git -C "$d" switch -qc yusuf-deneme
ekle "$d" proje-bilgileri/a.md "# a" "docs: not (#12)"
bekle "yanlis_dal_adi_kalir" 1 calistir "$d" dal

# 5. Yalnızca doküman: test commit'i aranmaz.
d=$(depo); git -C "$d" switch -qc docs/12-not
ekle "$d" proje-bilgileri/a.md "# a" "docs: not (#12)"
bekle "yalniz_dokuman_gecer" 0 calistir "$d" dal

# 6. Kurala uymayan commit mesajı.
d=$(depo); git -C "$d" switch -qc docs/12-not
ekle "$d" proje-bilgileri/a.md "# a" "güncelleme yapıldı"
bekle "yanlis_mesaj_kalir" 1 calistir "$d" dal

# 7. print ve default dalı commit öncesinde yakalanır.
d=$(depo)
printf "void f() { print('x'); }\n" > "$d/packages/server/lib/a.dart"; git -C "$d" add -A
bekle "print_yakalanir" 1 calistir "$d" staged
d=$(depo)
printf "int f(int x) {\n  switch (x) {\n    default:\n      return 0;\n  }\n}\n" > "$d/packages/server/lib/a.dart"; git -C "$d" add -A
bekle "default_yakalanir" 1 calistir "$d" staged

# 8. Test dosyasındaki print serbest; .env yasak.
d=$(depo)
printf "void main() { print('x'); }\n" > "$d/packages/server/test/a_test.dart"; git -C "$d" add -A
bekle "testte_print_serbest" 0 calistir "$d" staged
d=$(depo)
echo "JWT_SECRET=x" > "$d/.env"; git -C "$d" add -A
bekle "env_dosyasi_yakalanir" 1 calistir "$d" staged

# 9. Betik testi (-test.sh) test dosyası sayılır.
d=$(depo); git -C "$d" switch -qc chore/12-betik
ekle "$d" scripts/ornek-test.sh "echo test" "test: örnek betik sınanıyor (#12)"
ekle "$d" scripts/ornek.sh "echo ok" "chore: örnek betik (#12)"
bekle "sh_test_dosyasi_taninir" 0 calistir "$d" dal

# 10. commit-msg kipi.
f=$(mktemp); echo "feat: bildirim detayı (#159)" > "$f"
bekle "mesaj_kipi_gecer" 0 bash "$BETIK" mesaj "$f"
echo "detay eklendi" > "$f"
bekle "mesaj_kipi_kalir" 1 bash "$BETIK" mesaj "$f"

echo; echo "$gecen geçti, $kalan kaldı"
[ "$kalan" -eq 0 ]
