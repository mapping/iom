source 'http://rubygems.org'

gem 'rails', '3.0.1'

# PostgreSQL
gem 'pg',                       '0.9.0'
gem 'nofxx-georuby',                          :require => 'geo_ruby'
gem 'ppe-postgis-adapter',                    :require => 'postgis_adapter', :git => 'git://github.com/ferblape/postgis_adapter.git', :branch => 'load_geometry_optimization'

gem 'ruby-debug'

gem "will_paginate", "~> 3.0.pre2"
gem 'sanitize'
gem 'paperclip', :tag => 'v2.3.3'

group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
end

group :test do
  gem 'rr', :tag => 'v1.0.0'
  gem 'steak', :git => 'git://github.com/cavalle/steak.git'
  gem 'rspec', '>= 2.0.0.beta.13'
  gem "rspec-rails", ">= 2.0.0.beta.8"
  gem 'launchy'
  gem 'capybara', '~> 0.4.0'
  gem 'webrat'
  gem 'database_cleaner', :tag => 'v0.5.2'
end