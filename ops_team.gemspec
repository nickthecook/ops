# frozen_string_literal: true

Gem::Specification.new do |s|
	s.name = 'ops_team'
	s.version = '0.19.1'
	s.authors = [
		'nickthecook@gmail.com'
	]
	s.date = '2020-08-12'
	s.summary = 'ops_team handles basic operations tasks for your project, driven by YAML config'
	s.homepage = 'https://github.com/nickthecook/ops'
	s.files = Dir[
		'Gemfile',
		'bin/*',
		'lib/*',
		'etc/*',
		'lib/builtins/*',
		'lib/builtins/helpers/*',
		'lib/dependencies/*',
		'lib/dependencies/helpers/*',
		'loader.rb',
		'ops_team.gemspec'
	]
	s.executables << 'ops'
	s.required_ruby_version = '~> 2.5'
	s.add_runtime_dependency 'bcrypt_pbkdf', '~> 1.0', '>= 1.0.1'
	s.add_runtime_dependency 'colorize', '~> 0.8', '>= 0.8.1'
	s.add_runtime_dependency 'ed25519', '~> 1.2', '>= 1.2.4'
	s.add_runtime_dependency 'ejson', '~> 1.2', '>= 1.2.1'
	s.add_runtime_dependency 'net-ssh', '~> 6.1', '>= 6.1.0'
	s.add_runtime_dependency 'require_all', '~> 1.1', '>= 1.1.6'
	s.license = 'GPL-3.0-only'
end
