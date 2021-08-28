# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem "bcrypt_pbkdf"
gem "colorize"
gem 'concurrent-ruby', require: 'concurrent'
gem "e2mmap"
gem "ed25519"
gem "ejson"
gem "io-console"
gem "json", ">= 2.3.0"
gem "net-ssh"
gem "require_all"

group :test do
	gem "fuubar"
	gem "rspec"
end

group :development do
	gem "irb"
	gem "pry"
	gem "pry-byebug"
	gem "rerun"
	gem "rubocop"
end
