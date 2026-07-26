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

1. **`<x-dc>` template** — the markup, using `{{ expr }}` interpolation and inline `style`/`style-hover`/`onClick="{{ handler }}"` bindings. dc-runtime replaces `<x-dc>` with a `<div id="dc-root">` React root at boot.
2. **`<script type="text/x-dc" data-dc-script>`** — a `class Component extends DCLogic` block. `DCLogic` is a React-component-like base with `state`, `setState`, `props`, and lifecycle. This component deliberately holds **no reactive state**: `componentDidMount` drives every animation through direct DOM manipulation, because a `setState` re-render would reset animated `textContent` mid-flight. Do not reintroduce `setState` here without re-checking the count-up / typing logic.
3. **`renderVals()`** — the single method that returns the object bound into the template. **All page content — the `skills` and `projects` arrays, hover style objects — is hardcoded inside `renderVals()`.** To change portfolio copy/data, edit the arrays returned there, not the template.

`data-props` on the script tag is a JSON schema (editor metadata + defaults). It currently declares `revealOnScroll` and `$preview` (design-canvas dimensions).

**Theming: dark only.** The light/dark toggle, `[data-theme]` switching, and `portfolio-theme` localStorage persistence were all removed in the terminal redesign. The palette is a flat set of CSS variables on `:root` (`--bg`, `--text`, `--accent` neon green `#2ee6a6`, …). Change the accent by editing `--accent` alone.

### Interaction layer (`componentDidMount`)

Typing animation, mouse spotlight, metric count-up, ASCII progress bars, card hover tilt, and scroll reveal all live here as plain DOM code. Two guards matter:

- **Touch devices** (`(hover: none), (pointer: coarse)`) skip spotlight, tilt, and typing — pointer effects are meaningless without a cursor, and typing a wrapping tagline shoves the layout on narrow screens.
- **`prefers-reduced-motion`** short-circuits to `revealAll()` + `fillMetricsInstant()`, with a CSS safety net that neutralises transitions/animations globally.

All listeners are registered with a shared `AbortController` signal and torn down in `componentWillUnmount`, alongside the typing timer and the `IntersectionObserver`.

## support.js — do not hand-edit

`support.js` is **generated** (`// GENERATED from dc-runtime/src/*.ts — do not edit`). It is the bundled dc-runtime and the `dc-runtime/` source is not present in this repo. Its internal modules (visible as `// src/*.ts` section comments) are: `react`, `parse`, `boot`, `expr`, `encode`, `compile`, `logic`, `component`, `external`, `atomics`, `helmet`, `pseudo`, `registry`, `runtime`, `stream-state`, `index`. Key flow: `boot()` → `parseDcDocument()` (splits template / script / props) → registers a React component → `ReactDOM.createRoot(...).render(...)`. `sc-*` CSS classes and streaming placeholders belong to the runtime, not the portfolio. If the runtime genuinely needs changing, it must be rebuilt upstream (`cd dc-runtime && bun run build`), not patched here.

## Files

- `Portfolio.dc.html` — **the source**. Edit this for all content/layout/style changes.
- `index.html` — **generated** copy of `Portfolio.dc.html`, produced by `deploy.sh`. GitHub Pages serves this. Never edit by hand.
- `deploy.sh` — sync + verify + commit + push. The only sanctioned deployment path.
- `support.js` — generated dc-runtime bundle (treat as read-only).
- `assets/portrait.jpeg` — hero portrait referenced by the template.
- `assets/resume.pdf` — linked by the `[ resume.pdf ]` hero button and by the GitHub profile README. **Not committed yet**; the button 404s until it is added.
- `docs/specs/` — design specs (e.g. the terminal-redesign spec). Committed and authoritative.
- `.nojekyll` — required so GitHub Pages serves the files as-is.
- `uploads/` — git-ignored. Holds `증명사진.jpeg` (same as the portrait) and `DESIGN-apple.md`, an Apple-style design-system spec kept as a reference. Not available in a fresh clone.
- `.thumbnail` — a WebP preview image (binary, despite the name). Git-ignored.
