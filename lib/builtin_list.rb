# frozen_string_literal: true

class BuiltinList
	def names
		builtins.keys
	end

	def get(name)
		builtins[name]
	end

	def builtins
		@builtins ||= Builtins.constants.each_with_object({}) do |const_name, hash|
			const = Builtins.const_get(const_name, false)

			next unless const.is_a?(Class)

			hash[const_name] = const
		end
	end

	def commands
		@commands ||= builtins.each_with_object({}) do |(name, const), hash|
			if hash.include?(const)
				hash[const] << name
			else
				hash[const] = [name]
			end
		end
	end

end
