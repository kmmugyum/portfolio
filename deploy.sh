#!/usr/bin/env bash
# 포트폴리오 배포 스크립트.
# Portfolio.dc.html 을 index.html 로 동기화한 뒤 커밋 & push 하면
# GitHub Pages(https://kmmugyum.github.io/portfolio/)가 자동으로 갱신된다.
#
# index.html 은 이 스크립트가 만들어내는 생성물이다. 직접 편집하지 말 것.
# 모든 배포는 이 스크립트를 경유해야 두 파일이 갈라지지 않는다.
set -euo pipefail
cd "$(dirname "$0")"

cp Portfolio.dc.html index.html   # GitHub Pages 진입점 동기화

# 동기화가 실제로 성사됐는지 확인 — cp 실패나 권한 문제를 조용히 넘기지 않는다.
if ! cmp -s Portfolio.dc.html index.html; then
  echo "오류: index.html 동기화 실패 — Portfolio.dc.html 과 내용이 다릅니다." >&2
  exit 1
fi

# 배포에 필요한 것만 명시적으로 스테이징한다.
# `git add -A` 는 .gitignore 에 아직 등재되지 않은 신규 아티팩트까지
# 공개 저장소로 밀어넣을 수 있어 사용하지 않는다.
git add Portfolio.dc.html index.html
# 함께 커밋할 소스/문서가 있으면 추가 (없으면 조용히 통과)
for f in CLAUDE.md deploy.sh .gitignore .nojekyll; do
  [ -f "$f" ] && git add "$f"
done
[ -d docs ] && git add docs
[ -d assets ] && git add assets

if git diff --cached --quiet; then
  echo "변경 사항 없음 — 배포 생략."
  exit 0
fi

echo "=== 배포될 변경 ==="
git diff --cached --name-status

MSG="${1:-Update portfolio}"
git commit -m "$MSG"
git push origin main
echo "배포 완료: https://kmmugyum.github.io/portfolio/  (반영까지 최대 1~2분)"
