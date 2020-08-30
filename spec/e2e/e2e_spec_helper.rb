# frozen_string_literal: true

require 'open3'

shared_context "ops e2e" do
	ENV["OPS_RUNNING"] = nil

	def remove_untracked_files
		`git ls-files --others | grep -v '.rb$' | grep -v '$.yml' | xargs rm`
	end

	def run_ops(cmd, output_file = "ops.out")
		output, status = Open3.capture2e(cmd)

		File.open(output_file, "w") { |file| file.write(output) }

		[output, output_file, status.exitstatus]
	end
end
