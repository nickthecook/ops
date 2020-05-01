# frozen_string_literal: true

# for convenience, add "lib" to the load path
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/lib"))

# if this is the dev env, load some debugging tools
require 'pry-byebug' if ENV['environment'].nil? || ENV['environment'] == "development"
