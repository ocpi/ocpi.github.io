# Proposals Homepage Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Jekyll homepage that lists OCPI feature proposals from `_data/proposals.yaml` at generation time, published via GitHub Pages’ built-in Jekyll builder.

**Architecture:** Move proposal metadata into Jekyll’s `_data` directory. Render a sorted number+detail list on `index.markdown` via a Liquid include. Align the Gemfile with the `github-pages` gem and remove the obsolete Actions deploy workflow so branch-based Pages can build the site.

**Tech Stack:** Jekyll (via `github-pages`), Minima theme, Liquid, YAML data files, Minitest for build smoke tests, GitHub Pages branch deploy.

**Spec:** `docs/superpowers/specs/2026-08-13-proposals-homepage-design.md`

---

## File structure

| File | Responsibility |
| --- | --- |
| `_data/proposals.yaml` | Source of truth for proposal metadata |
| `_includes/proposals-list.html` | Liquid + HTML for the number+detail list |
| `index.markdown` | Homepage front matter + include hook |
| `_config.yml` | Site title and theme/plugins compatible with Pages |
| `Gemfile` / `Gemfile.lock` | `github-pages` gem for local/Pages parity |
| `test/proposals_homepage_test.rb` | Build the site and assert homepage HTML |
| `README.md` | Edit path, local preview, Pages branch-deploy note |
| `.github/workflows/pages.yml` | **Delete** (obsolete custom deploy) |
| `test/build_pages_test.rb` | **Delete** (targets removed `build-pages.rb`) |
| `proposals.yaml` (repo root) | **Remove** after move to `_data/` |

---

### Task 1: Align Gemfile with GitHub Pages

**Files:**
- Modify: `Gemfile`
- Modify: `Gemfile.lock` (via bundler)
- Modify: `_config.yml` (only if plugins/theme need tightening)

- [ ] **Step 1: Replace the Gemfile contents**

Write `Gemfile` as:

```ruby
source "https://rubygems.org"

# Match GitHub Pages’ built-in Jekyll builder.
# https://pages.github.com/versions/
gem "github-pages", group: :jekyll_plugins

# Windows and JRuby does not include zoneinfo files
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.1", :platforms => [:mingw, :x64_mingw, :mswin]
gem "http_parser.rb", "~> 0.6.0", :platforms => [:jruby]
```

- [ ] **Step 2: Ensure `_config.yml` theme/plugins match Pages**

Set / keep these keys in `_config.yml` (leave other keys; only change `title` in Task 4):

```yaml
theme: minima
plugins:
  - jekyll-feed
```

Do not add custom plugins under `_plugins/`.

- [ ] **Step 3: Install gems and verify a clean build**

Run:

```bash
bundle update
bundle exec jekyll build
```

Expected: build completes with exit code 0; `_site/index.html` exists.

- [ ] **Step 4: Commit**

```bash
git add Gemfile Gemfile.lock _config.yml
git commit -m "Align Gemfile with github-pages for branch deploys."
```

---

### Task 2: Add `_data/proposals.yaml` (fixed) and failing homepage test

**Files:**
- Create: `_data/proposals.yaml`
- Create: `test/proposals_homepage_test.rb`
- Delete: `proposals.yaml` (repo root) after the move
- Delete: `test/build_pages_test.rb`

- [ ] **Step 1: Write the failing test**

Create `test/proposals_homepage_test.rb`:

```ruby
require "minitest/autorun"
require "open3"
require "fileutils"

class ProposalsHomepageTest < Minitest::Test
  def setup
    @root = File.expand_path("..", __dir__)
    @site = File.join(@root, "_site")
  end

  def test_homepage_lists_proposals_from_data_file
    FileUtils.rm_rf(@site)

    stdout, stderr, status = Open3.capture3(
      "bundle", "exec", "jekyll", "build",
      chdir: @root
    )
    assert status.success?, "jekyll build failed:\n#{stdout}\n#{stderr}"

    index = File.read(File.join(@site, "index.html"))

    assert_includes index, "OCPI Feature Proposals"
    assert_includes index, "Processes for Feature Development for OCPI"
    assert_includes index, "extension-of-ocpi.pdf"
    assert_includes index, "0000"
    assert_includes index, "0010"
    assert_includes index, "Greg Fitzpatrick"
    assert_includes index, "Author:"
    assert_includes index, "Status:"
    assert_includes index, "Date:"

    # filename "-" must not render a Filename line for proposal 0001
    refute_match(/0001[\s\S]*?Filename:/, index)

    # proposals without date show an em dash
    assert_includes index, "Date: —"
  end
end
```

- [ ] **Step 2: Run the test to verify it fails**

Run:

```bash
bundle exec ruby test/proposals_homepage_test.rb
```

Expected: FAIL (missing `_data/proposals.yaml` and/or homepage content / title).

- [ ] **Step 3: Create `_data/proposals.yaml` from the root file, with YAML fixed**

```bash
mkdir -p _data
```

Write `_data/proposals.yaml` with the same proposals as today’s root file, but fix entry `0009` so `author` is valid YAML. Full file:

```yaml
proposals:
  - number: "0000"
    title: Processes for Feature Development for OCPI
    author: Reinier Lamers
    status: Draft
    date: 2026-08-06
    filename: extension-of-ocpi.pdf
  - number: "0001"
    title: "..."
    author: Philipp Fischbacher
    status: Accepted
    date: 2025
    filename: "-"
  - number: "0002"
    title: Bookings
    author: Michel Bayings, Boudewijn Groeneboer
    status: Accepted
    date: 2025
    filename: "-"
  - number: "0003"
    title: OCPI Discount Offer
    author: Hakan Ebabil, Matthew Penny
    status: Draft
    date: 2026
    filename: "-"
  - number: "0004"
    title: Loitering Fees with Grace Periods
    author: Reinier Lamers
    status: Draft
    date: 2026
    filename: loitering-fees-with-grace-periods.pdf
  - number: "0005"
    title: Accessibility Extension
    author: Ben van Gameren
    status: Accepted
    date: 2026
    filename: "-"
  - number: "0006"
    title: Autocharge Whitepaper
    author: Hakan Ebabil, Adão Viana Pinto
    status: Draft
    filename: "-"
  - number: "0007"
    title: Invoice Reconciliation for OCPI 2.3.0
    author: Ben van Gameren
    status: Accepted
    filename: "-"
  - number: "0008"
    title: OCPI Connector Status Extension Proposal
    author: Jens Andersson
    status: Proposed
    filename: "-"
  - number: "0009"
    title: "..."
    author: Greg Fitzpatrick
    status: Under Review
    filename: "-"
  - number: "0010"
    title: OCPI Data Exchange for National Access Points under AFIR
    author: Ben van Gameren
    status: Under Review
    filename: nap-extension-1.0-RC2.pdf
```

Notes:
- Quote `number` values so leading zeros survive YAML parsing.
- Quote `filename: "-"` and `title: "..."` so they stay strings.
- Keep `date` omitted where the source omitted it (`0006`–`0009`).

Then remove the root copy:

```bash
rm proposals.yaml
```

- [ ] **Step 4: Delete the obsolete build-pages test**

```bash
rm test/build_pages_test.rb
```

- [ ] **Step 5: Commit data move (test still expected to fail on assertions about rendered HTML)**

```bash
git add _data/proposals.yaml test/proposals_homepage_test.rb
git add -u proposals.yaml test/build_pages_test.rb
git commit -m "Add proposals data file and homepage build smoke test."
```

---

### Task 3: Render the proposals list on the homepage

**Files:**
- Create: `_includes/proposals-list.html`
- Modify: `index.markdown`
- Modify: `_config.yml`

- [ ] **Step 1: Add the Liquid include**

Create `_includes/proposals-list.html`:

```html
{% assign sorted_proposals = site.data.proposals.proposals | sort: "number" %}
<style>
  .proposals-list { list-style: none; padding: 0; margin: 1.5rem 0 0; }
  .proposal-row {
    display: grid;
    grid-template-columns: 4.5rem 1fr;
    gap: 0.75rem 1rem;
    padding: 0.85rem 0;
    border-bottom: 1px solid #e8e8e8;
  }
  .proposal-number { font-weight: 700; color: #666; }
  .proposal-title { font-weight: 600; margin: 0 0 0.25rem; }
  .proposal-meta, .proposal-filename { color: #666; font-size: 0.95rem; }
  .proposal-filename { margin-top: 0.15rem; }
</style>

<ul class="proposals-list">
  {% for proposal in sorted_proposals %}
    <li class="proposal-row">
      <div class="proposal-number">{{ proposal.number }}</div>
      <div class="proposal-detail">
        <div class="proposal-title">{{ proposal.title | escape }}</div>
        <div class="proposal-meta">
          Author: {{ proposal.author | escape }}
          · Status: {{ proposal.status | escape }}
          · Date: {% if proposal.date and proposal.date != "" %}{{ proposal.date | escape }}{% else %}—{% endif %}
        </div>
        {% assign fname = proposal.filename | strip %}
        {% if fname and fname != "" and fname != "-" %}
          <div class="proposal-filename">Filename: {{ fname | escape }}</div>
        {% endif %}
      </div>
    </li>
  {% endfor %}
</ul>
```

- [ ] **Step 2: Wire the homepage**

Replace `index.markdown` with:

```markdown
---
layout: home
title: OCPI Feature Proposals
---

{% include proposals-list.html %}
```

- [ ] **Step 3: Set the site title in `_config.yml`**

Change:

```yaml
title: Your awesome title
```

to:

```yaml
title: OCPI Feature Proposals
```

Also set a short real description (optional but recommended):

```yaml
description: >-
  Public list of OCPI feature proposals and their status.
```

Leave `email`, social usernames, and other placeholders unless you are already editing them; not required for this feature.

- [ ] **Step 4: Run the test to verify it passes**

Run:

```bash
bundle exec ruby test/proposals_homepage_test.rb
```

Expected: PASS.

If `Date: —` fails because every proposal somehow has a date, check YAML omissions for 0006–0009. If `refute_match` for 0001 fails, confirm `filename: "-"` and the strip/`-` check in the include.

- [ ] **Step 5: Spot-check in the browser (optional but useful)**

Run:

```bash
bundle exec jekyll serve
```

Open `http://127.0.0.1:4000/` and confirm number+detail rows, sorted order, and filenames only where expected.

- [ ] **Step 6: Commit**

```bash
git add _includes/proposals-list.html index.markdown _config.yml
git commit -m "Render sorted proposals list on the homepage."
```

---

### Task 4: Remove obsolete Pages Actions workflow

**Files:**
- Delete: `.github/workflows/pages.yml`

- [ ] **Step 1: Delete the workflow**

```bash
rm .github/workflows/pages.yml
```

If `.github/workflows/` is empty afterward, leave the empty directory untracked or remove it:

```bash
rmdir .github/workflows 2>/dev/null || true
rmdir .github 2>/dev/null || true
```

Only remove `.github` if it contains nothing else.

- [ ] **Step 2: Confirm no CI still references `build-pages.rb`**

Run:

```bash
rg -n "build-pages|pages-out" --glob '!.git/**' --glob '!_site/**' --glob '!pages-out/**' || true
```

Expected: no matches in tracked source (mentions only in this plan/spec or untracked `pages-out/` are fine).

- [ ] **Step 3: Commit**

```bash
git add -u .github
git commit -m "Remove obsolete GitHub Actions Pages workflow."
```

---

### Task 5: Update README for editors and Pages settings

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Replace README contents**

Write `README.md`:

```markdown
# OCPI Feature Proposals

This repository tracks feature proposals for OCPI:

* Assigns proposal numbers
* Stores proposal metadata in `_data/proposals.yaml`
* Publishes a public list on GitHub Pages

## Editing the list

1. Edit `_data/proposals.yaml`.
2. Preview locally (optional):

   ```bash
   bundle install
   bundle exec jekyll serve
   ```

   Open http://127.0.0.1:4000/
3. Commit and push to `main`. GitHub Pages’ built-in Jekyll builder regenerates the site.

## GitHub Pages settings

In the repository **Settings → Pages**:

* Source: **Deploy from a branch**
* Branch: **main** / **/ (root)**

Do **not** select “GitHub Actions” as the Pages source for this site.

## Proposal documents

AsciiDoc sources may live under `proposals/`. Linking those documents from the homepage is not wired up yet; the `filename` field is shown as plain text when present.
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "Document proposals data path and Pages branch deploy."
```

---

### Task 6: Final verification

**Files:** none (verification only)

- [ ] **Step 1: Full build + test**

Run:

```bash
bundle exec jekyll build
bundle exec ruby test/proposals_homepage_test.rb
```

Expected: both succeed; `_site/index.html` contains the proposals list.

- [ ] **Step 2: Manual checklist before calling done**

- [ ] `_data/proposals.yaml` exists; root `proposals.yaml` gone  
- [ ] Homepage uses number+detail layout, sorted by number  
- [ ] Filenames omitted for `-`  
- [ ] Missing dates show `—`  
- [ ] `.github/workflows/pages.yml` gone  
- [ ] README documents branch-deploy Pages setting  
- [ ] Remind the human to set **Settings → Pages → Deploy from a branch → main / root** if not already  

- [ ] **Step 3: No further commit required unless verification forced fixes**

If fixes were needed, commit them with a message that states why (e.g. `Fix filename blank handling on proposals list.`).

---

## Spec coverage check

| Spec requirement | Task |
| --- | --- |
| `_data/proposals.yaml` as source of truth | Task 2 |
| Fix invalid `author` YAML | Task 2 |
| Homepage `/` with layout home | Task 3 |
| Number + detail rows | Task 3 |
| Sort by number | Task 3 |
| Filename plain text; omit `-`/blank | Task 3 |
| Missing date → `—` | Task 3 |
| Site title OCPI Feature Proposals | Task 3 |
| `github-pages` Gemfile | Task 1 |
| Remove Actions workflow | Task 4 |
| Delete obsolete build-pages test | Task 2 |
| README (path, preview, Pages setting) | Task 5 |
| No PDF/AsciiDoc linking | Deferred (not implemented) |

## Deferred / not in this plan

- PDF or AsciiDoc links from `filename`
- Publishing `proposals/*.asciidoc`
- Deleting untracked `pages-out/`
- Status grouping / filters
- Automating the GitHub Pages settings toggle
