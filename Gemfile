source "http://rubygems.org"
gem "sinatra"
gem "log4r"
gem "rjb"
gem "libxml-ruby", :require => 'libxml'
gem "libxslt-ruby", :require => 'libxslt'
gem 'haml'
gem 'semver'

if RUBY_VERSION == "1.8.6"
  gem "rack", "~>1.0.0"
end

group :test do
  gem "cucumber"
  gem "rspec", :require => "spec"
  gem "ruby-debug", :require => "spec"
  gem "rack-test", :require => 'rack/test'
end

group :thin do
  gem 'thin'
end
