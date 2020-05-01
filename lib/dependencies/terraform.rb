# frozen_string_literal: true

require 'dependency'

module Dependencies
	class Terraform < Dependency
		def met?
			false
		end

		def always_act?
			true
		end

		def meet
			execute("cd #{name} && terraform init && terraform apply -input=false --auto-approve")
		end

		def unmeet
			execute("cd #{name} && terraform destroy -input=false --auto-approve")
		end
	end
end
