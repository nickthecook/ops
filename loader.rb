# frozen_string_literal: true

# for convenience, add "lib" to the load path
# $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/lib"))

require 'zeitwerk'

loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path("#{__dir__}/lib"))
loader.setup
