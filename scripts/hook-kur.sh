#!/usr/bin/env bash
# Görev adımları kancalarını bu klona kurar (bir kez çalıştırılır).
# Ne yapar: git'in kanca klasörünü depodaki .githooks/ yapar; böylece her commit'te
# scripts/gorev-kontrol.sh çalışır. Geri almak için: git config --unset core.hooksPath
set -eu
kok=$(git rev-parse --show-toplevel)
cd "$kok"
chmod +x .githooks/* scripts/gorev-kontrol.sh
git config core.hooksPath .githooks
echo "Kuruldu: core.hooksPath = $(git config --get core.hooksPath)"
echo "Her commit'te: kod kuralları (pre-commit) ve mesaj kuralı (commit-msg)."
echo "Her push'ta: dal kontrolü (pre-push). PR açmadan önce: bash scripts/gorev-kontrol.sh pr"
