source "https://rubygems.org"

# Match GitHub Pages’ built-in Jekyll builder.
# Pin major/minor so Bundler does not resolve an ancient github-pages release.
# https://pages.github.com/versions/
gem "github-pages", "~> 232", group: :jekyll_plugins

# Windows and JRuby does not include zoneinfo files
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.1", :platforms => [:mingw, :x64_mingw, :mswin]
gem "http_parser.rb", "~> 0.6.0", :platforms => [:jruby]

# Needed for local `jekyll serve` on Ruby 3+
gem "webrick", "~> 1.8"
