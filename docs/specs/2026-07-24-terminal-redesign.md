# 포트폴리오 전면 리디자인 — 터미널 / 모노스페이스

작성일: 2026-07-24
대상 파일: `Portfolio.dc.html` (단일 파일만 수정, `support.js`는 생성물이므로 불변)

## 목표

김무겸 개인 포트폴리오를 "ML 리서처의 터미널 환경"을 은유한 테크/모던·대담·인터랙티브한
단일 페이지로 전면 리디자인한다. 기존의 차분한 에디토리얼 미니멀 톤을 대체한다.

## 확정 결정

- **미감**: 터미널 / 모노스페이스. 검은 배경, 그리드 라인, 네온 액센트 하나.
- **장식 강도**: 풀 터미널 — 프롬프트 라인(`$ whoami`), 타이핑 애니메이션, 커서 블링크,
  ASCII 프로그레스 바, 지표 카운트업.
- **테마**: 다크 고정. 라이트/다크 토글 및 `[data-theme="dark"]` 분기 제거.
- **폰트**: IBM Plex Mono (본문·수치·헤딩 전반). 기존 Noto Serif KR 제거.
- **레이아웃**: 반응형 우선. 데스크탑은 넓게(약 860px), 모바일은 단일 컬럼으로 자연 축소.
- **인터랙션**: 적극적. 아래 목록 전부 구현하되 `prefers-reduced-motion` 존중.
- **액센트 색**: 구현 후 실제 화면을 보며 최종 결정. CSS 변수 `--accent` 하나로 관리해
  색만 교체하면 전체 반영되도록 설계.

## 콘텐츠 변경

- 태그라인: 기존 "Undergraduate AI researcher interested in Computer Vision & Security."
  → **"Deep Learning"** 중심으로. (Security / Computer Vision 문구 제거)
- 직함: **Undergraduate Researcher** 를 현재 상황으로 유지·강조.
- Skills / Projects 데이터 자체는 유지 (필요 시 표현만 터미널화).

## 섹션 구조

1. **상단 프롬프트 바** — `~/portfolio $ whoami` 형태. 우측 상태 표시(`● online` + 커서 블링크).
   테마 토글 제거.
2. **Hero** — 이름 `MuGyum Kim`을 큰 모노로, 로드 시 타이핑 애니메이션 + 커서 블링크.
   태그라인 `> Undergraduate Researcher — Deep Learning`도 타이핑. Lab/Univ/Status는
   `key: value` 모노 메타 블록. Email/GitHub는 `[ email ]` 브래킷 버튼, 호버 시 네온 글로우.
   배경에 그리드 + 마우스 추적 스포트라이트.
3. **Skills** — 헤더 `$ ls skills/`. 카테고리 `[languages]` 태그, 항목 모노 칩(호버 네온 보더).
   등장 시 stagger.
4. **Projects** — 헤더 `$ ls projects/`. 각 프로젝트를 레코드 카드로. `[01]` 넘버링.
   지표는 카운트업 애니메이션 + ASCII 프로그레스 바(`████████░ 94.8%`). 카드 호버 타일트 +
   네온 보더.
5. **Footer** — `$ exit` 프롬프트, 커서 블링크로 마무리. 저작권·링크 모노.

## 인터랙션 목록

1. Hero 타이핑 애니메이션 + 커서 블링크
2. 마우스 추적 스포트라이트(배경 광원)
3. 지표 카운트업 + ASCII 프로그레스 바 채워짐
4. 프로젝트 카드 호버 타일트 + 네온 글로우
5. 스크롤 시 섹션/라인 stagger 등장 (기존 reveal 확장)
6. 브래킷 버튼/칩 호버 글로우

## 기술 제약

- `Portfolio.dc.html` 한 파일만 수정. `support.js`(dc-runtime 번들) 불변.
- 콘텐츠/데이터/아이콘은 `renderVals()` 내부에 유지. 인터랙션 로직은 `componentDidMount`
  (현재 reveal 로직 위치)에 추가하고 dc-runtime의 `state`/`setState`/lifecycle 안에서 구현.
- `prefers-reduced-motion: reduce`면 모든 모션 비활성, 정적 최종 상태로 즉시 표시.
- 반응형: 데스크탑/모바일 두 폭 모두 검증.
