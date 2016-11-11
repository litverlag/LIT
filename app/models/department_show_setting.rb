# Access to the bool-arrays: gprods_options, buecher_options, status_options
class DepartmentShowSetting < ActiveRecord::Base
  belongs_to :department

	## 
	# I really thought it would be simpler, to enumerate a boolean array, instead
	# of creating a boolean field for every option in the database. But this is
	# not very.. readable.

	BUECHER_INDEX = {}
	GPROD_INDEX = {}
	STATUS_INDEX = {}
	constants = [BUECHER_INDEX, GPROD_INDEX, STATUS_INDEX]
	i18names = ['buecher_names', 'gprod_names', 'status_names']
	i18list = []
	i18names.each {|n| i18list.append(I18n.t(n).keys)}
	constants.zip(i18list).each do |c|
		i = 0
		c[1].each do |opt|
			c[0].update(opt => i)
			i += 1
		end
		puts c[0]
	end

	#constants.each {|c| puts c}

	{'buecher_names' => 'buecher_options', 
	 'gprod_names' => 'gprods_options', 
	 'status_names' => 'status_options'}.each do |i18name, column|
		I18n.t(i18name).keys.each do |m|
			i = 0
			# Create getter ..
			define_method(m) do
				if i18name.include? 'gprod'
					gprods_options[GPROD_INDEX[m]]
				elsif i18name.include? 'buecher'
					buecher_options[BUECHER_INDEX[m]]
				elsif i18name.include? 'status'
					status_options[STATUS_INDEX[m]]
				else
					raise ArgumentError, "#{m}::#{value}"
				end
			end
			# .. and setter for every gprods,buecher,status table entry.
			define_method("#{m}=") do |value|
				if i18name.include? 'gprod'
					gprods_options[GPROD_INDEX[m]] = value
				elsif i18name.include? 'buecher'
					buecher_options[BUECHER_INDEX[m]] = value
				elsif i18name.include? 'status'
					status_options[STATUS_INDEX[m]] = value
				else
					raise ArgumentError, "#{m}::#{value}"
				end
			end
			i += 1
		end
	end
end
