# frozen_string_literal: true

Gem::Specification.new do |s|
	s.name = 'ops_team'
	s.version = '1.21.1'
	s.authors = [
		'nickthecook@gmail.com'
	]
	s.date = '2022-06-11'
	s.summary = 'ops_team handles basic automation for your project, driven by self-documenting YAML config'
	s.homepage = 'https://github.com/nickthecook/ops'
	s.files = Dir[
		'Gemfile',
		'bin/*',
		'lib/*',
		'etc/*',
		'lib/builtins/*',
		'lib/builtins/helpers/*',
		'lib/builtins/common/*',
		'lib/dependencies/*',
		'lib/dependencies/helpers/*',
		'loader.rb',
		'ops_team.gemspec'
	]
	s.executables << 'ops'
	s.required_ruby_version = '> 2.6'
	s.add_runtime_dependency 'bcrypt_pbkdf', '~> 1.0', '>= 1.0.1'
	s.add_runtime_dependency 'colorize', '~> 0.8', '>= 0.8.1'
	s.add_runtime_dependency 'concurrent-ruby', '~> 1.1', '>= 1.1.7'
	s.add_runtime_dependency 'ed25519', '~> 1.2', '>= 1.2.4'
	s.add_runtime_dependency 'ejson', '~> 1.2', '>= 1.2.1'
	s.add_runtime_dependency 'net-ssh', '~> 7.1', '>= 7.1.0'
	s.add_runtime_dependency 'require_all', '~> 1.1', '>= 1.1.6'
	s.add_runtime_dependency 'zeitwerk', '~> 2.5', '>= 2.5.3'
	s.license = 'GPL-3.0-only'
end
