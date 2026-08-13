# Proposals Homepage from YAML — Design

**Date:** 2026-08-13  
**Status:** Approved for planning  
**Repo:** ocpi.github.io

## Goal

Publish a homepage that lists OCPI feature proposals from a YAML file, built at Jekyll generation time, and served via GitHub Pages. Editors update the YAML and push; Pages regenerates the site.

## Decisions (from brainstorming)

| Topic | Choice |
| --- | --- |
| Page location | Homepage (`/`) |
| Filename field | Show as plain text; no links yet |
| Ordering | Single list sorted by proposal number |
| Data loading | Jekyll `_data` file |
| List layout | Number + detail rows (number left, details right) |
| Publishing | GitHub Pages built-in Jekyll (not a custom Actions build) |

## Architecture

```
_data/proposals.yaml  ──(Jekyll build)──►  site.data.proposals
                                              │
index (Liquid)  ◄─────────────────────────────┘
                                              │
GitHub Pages (branch deploy, built-in Jekyll) ──► public site
```

- **Source of truth:** `_data/proposals.yaml` (moved from repo-root `proposals.yaml`).
- **Access in templates:** `site.data.proposals.proposals` (file name `proposals` + top-level key `proposals`).
- **No custom plugins.** Only features supported by GitHub Pages’ `github-pages` gemset (Minima, `jekyll-feed`, data files).

## Data shape

Keep the existing structure:

```yaml
proposals:
  - number: 0000
    title: ...
    author: ...
    status: Draft | Accepted | Proposed | Under Review | ...
    date: ...          # optional / inconsistent formats OK to display as-is
    filename: ...      # PDF name; omit from UI when blank or `-`
```

**Required fix before build:** repair invalid YAML (`author Greg Fitzpatrick` → `author: Greg Fitzpatrick`).

**Sorting:** by `number` ascending (string sort is fine while numbers stay zero-padded to four digits).

## Homepage UI

- Implement on `index.markdown` with Minima `layout: home` so `/` is the proposals list (blog post index below content can stay empty / unused).
- Site title: **OCPI Feature Proposals** in `_config.yml` (replace placeholder “Your awesome title”). Page heading matches.
- No intro paragraph required for MVP.
- Each proposal rendered as a **number + detail row**:
  - Left: proposal `number`
  - Right: `title` (emphasis); secondary line `Author: … · Status: … · Date: …`; tertiary line `Filename: …` only when `filename` is present and not `-`
- Missing `date`: show `—` in the secondary line. Missing/`-` `filename`: omit the filename line entirely.

No status grouping, filters, or PDF links in this iteration.

## Publishing & local build

1. **GitHub Pages setting (manual, document in README):**  
   Settings → Pages → Deploy from a branch → `main` / `/` (root).  
   Do **not** use “GitHub Actions” as the Pages source for this design.

2. **Remove** `.github/workflows/pages.yml` so the obsolete `build-pages.rb` / `pages-out` pipeline cannot conflict or fail on push.

3. **Gemfile:** switch to the `github-pages` gem (local parity with Pages’ builder). Keep Minima via what `github-pages` provides / allows.

4. **Local workflow:** edit `_data/proposals.yaml`, run `bundle exec jekyll serve`, verify homepage.

## Cleanup in scope

- Move `proposals.yaml` → `_data/proposals.yaml`
- Fix YAML syntax error noted above
- Delete obsolete `test/build_pages_test.rb` (targets removed `build-pages.rb`)
- Remove `.github/workflows/pages.yml`
- Update README with: data file path, how to preview locally, and Pages branch-deploy requirement

## Out of scope (deferred)

- Linking `filename` to hosted PDFs or AsciiDoc HTML
- Rendering / publishing content under `proposals/*.asciidoc`
- Reusing or redeploying `pages-out/`
- Status-based grouping or client-side sorting
- Broader site branding / design system work beyond title + list layout
- Automating the GitHub Pages “branch deploy” setting via API/terraform

## Success criteria

- Pushing a change to `_data/proposals.yaml` on `main` results in an updated homepage on GitHub Pages without a custom build workflow.
- Homepage lists all proposals sorted by number in the number + detail layout.
- `bundle exec jekyll build` succeeds locally with the `github-pages`-aligned Gemfile.
- No reference to `build-pages.rb` remains in CI.

## Recommended next step

Write an implementation plan (`writing-plans`), then implement.

## Deferred / not now

See **Out of scope** above.
