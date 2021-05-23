# frozen_string_literal: true

module Builtins
	module Helpers
		class Enumerator
			class << self
				def names_by_constant
					constants_by_name.each_with_object({}) do |(name, const), hash|
						if hash.include?(const)
							hash[const] << name
						else
							hash[const] = [name]
						end
					end
				end

				private

				def constants_by_name
					@constants_by_name = Builtins.constants.each_with_object({}) do |const_name, hash|
						const = Builtins.const_get(const_name, false)

						next unless const.is_a?(Class)

						hash[const_name] = const
					end
				end
			end
		end
	end
end
