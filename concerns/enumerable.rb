# frozen_string_literal: true

def enumeration
	names.each_with_object({}) do |name, object|
		object[name] = description
	end
end

def names
	raise NotImplementedError
end

def description
	raise NotImplementedError
end
