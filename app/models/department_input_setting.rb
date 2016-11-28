class DepartmentInputSetting < ActiveRecord::Base
  belongs_to :department
	#has_one :department

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
	constants.zip(i18list).each do |const, table|
		i = 0
		table.each do |opt|
			const.update(opt => i)
			i += 1
		end
	end

	# Methaprogramming madness.
	{'buecher_names' => 'buecher_options', 
	 'gprod_names' => 'gprods_options', 
	 'status_names' => 'status_options'}.each do |i18name, column|
		I18n.t(i18name).keys.each do |m|
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
		end
	end

	def self.option_attrs
		self.attribute_names.clone.delete_if { |m| not m =~ /_options$/ }
	end
	def self.save_persistent(fname)
		File.open("#{Rails.root}/config/#{fname}.yml", 'w') do |file|
			InputSettings.instance.all('gprods')
			file.write DepartmentInputSetting.all.map { |s|
				DepartmentInputSetting.option_attrs.map { |opt|
					{opt.to_sym => s.send(opt)}
				}
			}.to_yaml
		end
	end
	def self.load_persistent(fname)
		yml = YAML.load_file("#{Rails.root}/config/#{fname}.yml")
		yml.each do |dep|
			dep.each do |dict|
				if dict.keys.count != 1 # Cannot happen.
					raise LoadError, "DepartmentInputSetting id:#{yml.index(dep) + 1}" 
				end
				dep_settings = self.where(id: yml.index(dep) + 1).first
				dep_settings.send("#{dict.keys[0]}=", dict.values[0])
				dep_settings.save!
			end
		end
	end

end
