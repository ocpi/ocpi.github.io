# OCPI Standard Extension overview page

This repository generates a Github Pages view of standard extensions proposals for OCPI:

* Reads the metadata of proposals written in AsciiDoc from the header attributes
  (`:evrf-number:`, `:author:`, `:revdate:`, `:evrf-status:`) of their documents
  in [ocpi/extensions](https://github.com/ocpi/extensions), and publishes their PDFs
* Stores the metadata of other proposals in `_data/proposals.yaml`
* Publishes a public list on GitHub Pages

The site is built and deployed by `.github/workflows/pages.yml`, on every push
here and on every push to the main branch of ocpi/extensions.

## Editing the list

1. Edit the AsciiDoc document in ocpi/extensions, or for other proposals,
   `_data/proposals.yaml`.
2. Preview locally (optional), with ocpi/extensions checked out next to this
   repository and its PDFs built with `make`:

   ```bash
   bundle install
   EXTENSIONS_DIR=../extensions bundle exec jekyll serve
   ```

   Open http://127.0.0.1:4000/

## Tests

```bash
bundle exec ruby test/extension_proposals_test.rb
```
