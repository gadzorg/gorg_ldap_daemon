source 'https://rubygems.org'

ruby File.read(".ruby-version").strip

gem 'gram_v2_client', git: 'https://github.com/gadzorg/gram2_api_client_ruby.git'
gem 'gorg_service', "~> 6.0"

gem 'net-ldap'
gem 'activeldap'

group :development, :test do
  gem 'rspec'
  gem 'byebug'
  gem 'bogus'
end

group :test do
  gem "simplecov"
  gem "codeclimate-test-reporter", "~> 1.0.0"
end
