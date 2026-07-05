#!/usr/bin/env bash
# 포트폴리오 배포 스크립트.
# Portfolio.dc.html 을 index.html 로 동기화한 뒤 커밋 & push 하면
# GitHub Pages(https://kmmugyum.github.io/portfolio/)가 자동으로 갱신된다.
set -euo pipefail
cd "$(dirname "$0")"

cp Portfolio.dc.html index.html   # GitHub Pages 진입점 동기화

git add -A
if git diff --cached --quiet; then
  echo "변경 사항 없음 — 배포 생략."
  exit 0
fi

MSG="${1:-Update portfolio}"
git commit -m "$MSG"
git push origin main
echo "배포 완료: https://kmmugyum.github.io/portfolio/  (반영까지 최대 1~2분)"
