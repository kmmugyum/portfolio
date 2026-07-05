# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A single-page personal portfolio (김무겸 / MuGyum Kim, undergraduate ML researcher) rendered by a custom client-side runtime called **dc-runtime**. There is no build step, package manager, or server in this repo — it is a static site opened directly in a browser. Not a git repository.

To preview: open `Portfolio.dc.html` in a browser (dc-runtime boots on `DOMContentLoaded` and renders into `#dc-root`).

## Architecture

The whole page is one file, `Portfolio.dc.html`, driven by `support.js`. Three cooperating parts:

1. **`<x-dc>` template** — the markup, using `{{ expr }}` interpolation and inline `style`/`style-hover`/`onClick="{{ handler }}"` bindings. dc-runtime replaces `<x-dc>` with a `<div id="dc-root">` React root at boot.
2. **`<script type="text/x-dc" data-dc-script>`** — a `class Component extends DCLogic` block. `DCLogic` is a React-component-like base: it has `state`, `setState`, `props`, and lifecycle (`componentDidMount`). This is where theme toggling, scroll-reveal (`IntersectionObserver` over `[data-reveal]`), and localStorage persistence (`portfolio-theme`) live.
3. **`renderVals()`** — the single method that returns the object bound into the template. **All page content — the `skills` and `projects` arrays, inline SVG icons, hover style objects — is hardcoded inside `renderVals()`.** To change portfolio copy/data, edit the arrays returned there, not the template.

`data-props` on the script tag is a JSON schema (editor metadata + defaults) for props like `defaultTheme` (`system|light|dark`) and `revealOnScroll`. `$preview` sets the design-canvas dimensions.

Theming is CSS-variable based: `:root` and `[data-theme="dark"]` define the palette; the template's outer `<div data-theme="{{ theme }}">` switches it.

## support.js — do not hand-edit

`support.js` is **generated** (`// GENERATED from dc-runtime/src/*.ts — do not edit`). It is the bundled dc-runtime and the `dc-runtime/` source is not present in this repo. Its internal modules (visible as `// src/*.ts` section comments) are: `react`, `parse`, `boot`, `expr`, `encode`, `compile`, `logic`, `component`, `external`, `atomics`, `helmet`, `pseudo`, `registry`, `runtime`, `stream-state`, `index`. Key flow: `boot()` → `parseDcDocument()` (splits template / script / props) → registers a React component → `ReactDOM.createRoot(...).render(...)`. `sc-*` CSS classes and streaming placeholders belong to the runtime, not the portfolio. If the runtime genuinely needs changing, it must be rebuilt upstream (`cd dc-runtime && bun run build`), not patched here.

## Files

- `Portfolio.dc.html` — the portfolio (edit this for all content/layout/style changes).
- `support.js` — generated dc-runtime bundle (treat as read-only).
- `assets/portrait.jpeg` — hero portrait referenced by the template. `uploads/증명사진.jpeg` is the same image; `uploads/` also holds `DESIGN-apple.md`.
- `uploads/DESIGN-apple.md` — an Apple-style design-system spec (colors, typography scale, spacing, component rules, do's/don'ts). Reference it as the design north-star when restyling; the live palette in the HTML is a distinct, simpler token set and does not import from this file.
- `.thumbnail` — a WebP preview image (binary, despite the name).
