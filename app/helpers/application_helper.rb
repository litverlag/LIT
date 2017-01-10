module ApplicationHelper

	# Fix for braindead show/input setting implementation.
	def class_to_dep(dep)
		case dep
		when /projekt/i
			return 'Lektor'
		when /preps/i
			return 'PrePs'
		when /druck/i
			return 'Pod'
		end
		puts "Input not found: #{dep}"
		return
	end

end
