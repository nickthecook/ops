# frozen_string_literal: true

Gem::Specification.new do |s|
	s.name = 'ops'
	s.version = '0.0.10'
	s.authors = [
		'nick@rmtly.com'
	]
	s.date = '2018-09-17'
	s.summary = 'ops handles basic setup tasks for your project, driven by YAML config'
	s.files = Dir[
		'Gemfile',
		'bin/*',
		'lib/*',
		'etc/*',
		'lib/builtins/*',
		'lib/builtins/helpers/*',
		'lib/dependencies/*'
	]
	s.executables << 'ops'
	s.add_runtime_dependency 'require_all', '~> 1.1', '>= 1.1.6'
end
