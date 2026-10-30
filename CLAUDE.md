# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A single-page personal portfolio (김무겸 / MuGyum Kim, undergraduate ML researcher) rendered by a custom client-side runtime called **dc-runtime**. There is no build step, package manager, or server in this repo — it is a static site. It **is** a git repository, published to GitHub Pages at https://kmmugyum.github.io/portfolio/ from the `main` branch.

To preview: serve the directory (e.g. `python3 -m http.server`) and open `Portfolio.dc.html`. dc-runtime boots on `DOMContentLoaded` and renders into `#dc-root`. Opening via `file://` is unreliable because the runtime fetches `support.js` relatively.

## Deployment — always go through `deploy.sh`

`index.html` is a **generated copy** of `Portfolio.dc.html` — it is what GitHub Pages actually serves. `deploy.sh` performs the copy, verifies it with `cmp`, stages explicit paths, commits, and pushes.

**Never edit `index.html` by hand, and never commit a `Portfolio.dc.html` change without running `./deploy.sh`** — bypassing the script lets source and published output drift (this has happened before, leaving production stale).

```bash
./deploy.sh "commit message"
```

## Architecture

The whole page is one file, `Portfolio.dc.html`, driven by `support.js`. Three cooperating parts:

1. **`<x-dc>` template** — the markup, using `{{ expr }}` interpolation, `<sc-for>` loops, and `<sc-if>` conditionals. Styling lives in one `<style>` block inside `<helmet>`, as classes on top of OKLCH tokens in `:root` (no inline styles). dc-runtime replaces `<x-dc>` with a `<div id="dc-root">` React root at boot. `<title>`, meta description, and Open Graph tags sit in the real `<head>`.
2. **`<script type="text/x-dc" data-dc-script>`** — a `class Component extends DCLogic` block. It holds **no reactive state**. `componentDidMount` (a) highlights the current section in the table-of-contents rail via an `IntersectionObserver`, and (b) turns each `details.more` toggle into a curtain: the summary click is intercepted and the `.more-body` wrapper animates height + opacity (Web Animations API) before `open` flips. Under `prefers-reduced-motion` the native instant toggle is kept. Listeners share one `AbortController`; `componentWillUnmount` aborts it and disconnects the observer.
3. **`renderVals()`** — the single method that returns the object bound into the template. **All page content — the `news`, `publications`, `projects`, `studies`, and `skills` arrays — is hardcoded inside `renderVals()`.** To change portfolio copy/data, edit the arrays returned there, not the template. Each `projects` / `studies` entry renders as one panel modelled on popular researcher sites (Jon Barron's template for thumbnails, al-folio's abstract toggle): the always-visible head is `thumb` (3:2 JPEG in `assets/thumbs/`, 480×320) + `title` / `period` / `org` + a one-line `summary`, with `metric` + `metricLabel` top-right (`''` hides it; keep `metricLabel` Latin because it is set in mono) and the bold one-line `takeaway` under it. The 문제 → 해결 → 결과 detail sits inside a closed `<details>`: `problem`, `solution`, `result` are arrays of one-line noun-phrase bullets (`→` for cause/effect), `how` names the solution, and `note` states the condition limiting a figure (`※`, under the result). `projects` is ordered newest end date first. Each `publications` entry has `thumb`, `summary`, and an author list split into `authorsBefore` / `self` / `authorsAfter` so the owner's name renders bold. `news` items are one short line each. The NAME block shows `assets/portrait-sm.jpg` (208×248 crop of `portrait.jpeg`) and icon links. Awards, scholarships, GPA, and club activities are deliberately left to `resume.pdf`, not the site.

**Bold emphasis:** inside `summary`, `takeaway`, and every `problem` / `solution` / `result` bullet (and `publications[].summary`), wrap key figures or keywords in `**…**`. `renderVals()` splits these strings with `rich()` into `{t, k}` segments (`enrich()` applies it per entry), and the template renders each as `<span class="seg-b">` (bold; accent-coloured inside the takeaway) or `seg-n`. Keep emphasis to the one or two facts a reader should catch per line.

`data-props` on the script tag only declares `$preview` (design-canvas dimensions).

**Design: Long Document, dark only.** Redesigned in Oct 2026 with the Hallmark skill (the previous terminal design is preserved at git tag `design-v1-terminal` / branch `backup/design-v1-terminal`). Layout: a sticky man-page-style table-of-contents rail on the left (horizontal scroll strip on ≤720px) and one prose column (~66ch) on the right; sections are NAME → NEWS → PUBLICATIONS → RESEARCH → STUDIES → SKILLS. Colours, fonts, and spacing are `--color-*`, `--font-*`, `--space-*` tokens on `:root`; change the accent by editing `--color-accent` alone. Korean text must use `--font-ko` (Pretendard) — IBM Plex Mono has no Hangul, so mono is reserved for dates, numbers, section labels, and paths. There is no entrance animation, glow, or pointer effect by design.

## support.js — do not hand-edit

`support.js` is **generated** (`// GENERATED from dc-runtime/src/*.ts — do not edit`). It is the bundled dc-runtime and the `dc-runtime/` source is not present in this repo. Its internal modules (visible as `// src/*.ts` section comments) are: `react`, `parse`, `boot`, `expr`, `encode`, `compile`, `logic`, `component`, `external`, `atomics`, `helmet`, `pseudo`, `registry`, `runtime`, `stream-state`, `index`. Key flow: `boot()` → `parseDcDocument()` (splits template / script / props) → registers a React component → `ReactDOM.createRoot(...).render(...)`. `sc-*` CSS classes and streaming placeholders belong to the runtime, not the portfolio. If the runtime genuinely needs changing, it must be rebuilt upstream (`cd dc-runtime && bun run build`), not patched here.

## Files

- `Portfolio.dc.html` — **the source**. Edit this for all content/layout/style changes.
- `index.html` — **generated** copy of `Portfolio.dc.html`, produced by `deploy.sh`. GitHub Pages serves this. Never edit by hand.
- `deploy.sh` — sync + verify + commit + push. The only sanctioned deployment path.
- `support.js` — generated dc-runtime bundle (treat as read-only).
- `assets/portrait.jpeg` — hero portrait referenced by the template.
- `assets/resume.pdf` — linked by the `[ resume.pdf ]` hero button and by the GitHub profile README. One page, built with LaTeX (Awesome-CV, XeTeX port) from `~/Documents/01_이력서_포트폴리오/resume-latex/` — **not** in this repo, because the submission variant carries the phone number. Rebuild with `~/.local/bin/tectonic -X compile resume.tex` there (public, no phone) and copy `resume.pdf` here; `resume-submission.tex` produces the private copy with the phone number. Keep the resume's skills in sync with the site's `skills` array.
- `assets/Title.docx` — a DDPM report outline draft, **not** the resume source. Git-ignored.
- `docs/specs/` — design specs (e.g. the terminal-redesign spec). Committed and authoritative.
- `.nojekyll` — required so GitHub Pages serves the files as-is.
- `uploads/` — git-ignored. Holds `증명사진.jpeg` (same as the portrait) and `DESIGN-apple.md`, an Apple-style design-system spec kept as a reference. Not available in a fresh clone.
- `.thumbnail` — a WebP preview image (binary, despite the name). Git-ignored.
- `.omc/`, `.claude/`, `.playwright-mcp/` — local tool state (agent memory/specs, Claude settings, Playwright logs). Git-ignored. `.claude/skills/` holds symlinks to design skills (`hallmark`, `frontend-design`, `design-taste-frontend`, `web-design-guidelines`, `emil-design-eng`, `ui-ux-pro-max`, `design-reference-finder`) from `~/.claude/skills` and installed Claude plugins, so they load only in this project. The `ui-ux-pro-max` link points at a versioned plugin cache path and breaks when that plugin is upgraded.
