#!/usr/bin/env bash
# Yığın (stacked) PR birleştirme güvenlik kontrolü.
#
# Kullanım: scripts/pr-birlesme-kontrolu.sh <PR-numarası>
#
# Neden: `gh pr merge --delete-branch` ile bir PR'ın head dalı silindiğinde,
# o dalı base alan açık PR'ları GitHub OTOMATİK KAPATIR ve yeniden açmaya izin
# vermez (2026-10-17 #60, 2026-11-01 #112/#114 olayları).
#
# Script, verilen PR'ın head dalını base alan başka açık PR varsa 1 ile çıkar.
# 0 dönerse dalı silmek güvenlidir (ya da --delete-branch kullanılabilir).

set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
  echo "hata: gh (GitHub CLI) bulunamadı" >&2
  exit 2
fi

pr="${1:-}"
if [[ -z "$pr" ]]; then
  echo "kullanım: $0 <PR-numarası>" >&2
  exit 2
fi

head_branch="$(gh pr view "$pr" --json headRefName -q .headRefName)"
base_branch="$(gh pr view "$pr" --json baseRefName -q .baseRefName)"

echo "PR #$pr: $head_branch -> $base_branch"

if [[ "$base_branch" != "main" ]]; then
  echo "uyarı: bu PR main dışında bir tabana dayanıyor ($base_branch)."
  echo "       Yığın sırasını bozmadan birleştirdiğinizden emin olun."
fi

children="$(gh pr list --state open --limit 100 --json number,baseRefName \
  -q ".[] | select(.baseRefName == \"$head_branch\") | .number")"

if [[ -n "$children" ]]; then
  echo
  echo "ENGELLENDİ: şu açık PR'lar '$head_branch' dalını base alıyor:"
  for child in $children; do
    echo "  - #$child"
  done
  echo
  echo "Önce bu PR'ları main'e retarget edin (gh pr edit <no> --base main),"
  echo "sonra bu PR'ı --delete-branch ile birleştirin."
  exit 1
fi

echo "güvenli: '$head_branch' dalını base alan açık PR yok."
exit 0
