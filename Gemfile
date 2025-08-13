source "https://rubygems.org"

# Jekyll and plugins
gem "jekyll", "~> 4.3"
gem "jekyll-feed", "~> 0.12"
gem "jekyll-sitemap", "~> 1.4"
gem "jekyll-seo-tag", "~> 2.6"

# Theme (optional)
gem "minima", "~> 2.5"

# Performance and optimization
gem "jekyll-compress-images", "~> 1.2"
gem "jekyll-babel", "~> 1.0"

# Development dependencies
group :development do
  gem "webrick", "~> 1.7"
  gem "jekyll-admin", "~> 0.11"
end

# Windows and JRuby specific gems
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.1", :platforms => [:mingw, :x64_mingw, :mswin]

# Lock `http_parser.rb` gem to `v0.6.x` on JRuby builds
gem "http_parser.rb", "~> 0.6.0", :platforms => [:jruby]