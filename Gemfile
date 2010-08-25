# A sample Gemfile
source "http://rubygems.org"
#
gem 'curb'
gem 'nokogiri'
gem 'json'

# Make sure the correct version of xmpp4r-simple is loaded when
# require is called in bin/gv-notifier
if RUBY_VERSION < '1.9'
  gem 'xmpp4r-simple', "= 0.8.8"
else
  gem 'scashin133-xmpp4r-simple', '= 0.8.9'
end

group :test do
  gem 'shoulda'
  gem 'mocha'
end
