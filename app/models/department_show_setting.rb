# Access to the bool-arrays: gprods_options, buecher_options, status_options
class DepartmentShowSetting < ActiveRecord::Base
  belongs_to :department

	## 
	# Attention mad syntax incoming.
	#
	# Create static getter ..
	class << self
		['buecher_names', 'gprod_names', 'status_names'].each do |thingy|
			I18n.t(thingy).keys.each do |m|
				i = 0
				define_method(m) do
					self.gprod_options[i]
				end
				# .. and setter for every gprods table entry.
				define_method("#{m}=") do |value|
					self.gprod_options[i] = value
				end
				i += 1
			end
		end
	end
end
