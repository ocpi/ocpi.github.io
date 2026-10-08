# OCPI Standard Extension overview page

This repository generates a Github Pages view of standard extensions proposals for OCPI:

* Reads the metadata of proposals written in AsciiDoc from the Makefile in their
  `EVRF-NNN` folder in [ocpi/extensions](https://github.com/ocpi/extensions)
  (`NAME`, `VERSION`, `AUTHOR`, `STATUS`, and where set, `TITLE` and `DATE`),
  and publishes their PDFs (`out/<NAME>-<VERSION>.pdf`)
* Stores in `_data/proposals.yaml` the title and date of AsciiDoc proposals whose
  Makefile does not set them yet, and all metadata of proposals not written in
  AsciiDoc. Where both have a value, the Makefile wins.
* Publishes a public list on GitHub Pages

The site is built and deployed by `.github/workflows/pages.yml`, on every push
here and on every push to the main branch of ocpi/extensions.

## Editing the list

1. Edit the proposal's Makefile in ocpi/extensions, or for what it does not set,
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
