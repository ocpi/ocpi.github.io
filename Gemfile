source "https://rubygems.org"

# The site is built by .github/workflows/pages.yml rather than GitHub Pages'
# built-in builder, because the github-pages gem forces safe mode, which
# disables the plugins in _plugins. Versions match github-pages 232.
gem "jekyll", "~> 3.10.0"
gem "kramdown-parser-gfm", "~> 1.1"
gem "minima", "~> 2.5.1"

group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.17"
end

# Windows and JRuby does not include zoneinfo files
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.1", :platforms => [:mingw, :x64_mingw, :mswin]
gem "http_parser.rb", "~> 0.6.0", :platforms => [:jruby]

# Reads proposal metadata from the AsciiDoc documents in ocpi/extensions
# (see _plugins/extension_proposals.rb).
gem "asciidoctor", "~> 2.0"

# Needed for local `jekyll serve` on Ruby 3+
gem "webrick", "~> 1.8"

# Formerly-default stdlib gems that Ruby 3.4+ no longer loads implicitly but
# Jekyll 3.10 requires.
gem "base64"
gem "bigdecimal"
gem "csv"
gem "logger"

group :test do
  gem "minitest", "~> 5.25"
end
