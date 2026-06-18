#!/bin/sh

set -e

mkdir pages-out

for proposal_dir in proposals/* ; do
  cd "$proposal_dir"
  asciidoctor *.asciidoc
  proposal_title=`grep '^= ' *.asciidoc`
  echo proposal_title >> pages-out/index.html
  cd ../..
done
