# frozen_string_literal: true

require_relative "../dependency"

module Dependencies
	class Terraform < Dependency
		def met?
			# always return false; `terraform approve` is idempotent and this will save time
			false
		end

		def meet
			execute("cd #{name} && terraform init && terraform apply --auto-approve")
		end

		def unmeet
			execute("cd #{name} && terraform destroy --auto-approve")
		end
	end
end
