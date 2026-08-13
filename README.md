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
