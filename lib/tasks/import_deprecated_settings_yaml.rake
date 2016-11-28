namespace :db do
	desc "Gets old input and show settings from those .yaml files."
	task getoldsettings: :environment do
		puts "-begin- getoldsettings task"

		dict = {
			'projekt'		=>		'Lektor',
			'druck'		=>			'Pod',
			'preps'		=>			'PrePs',
		}

		{ 
			DepartmentInputSetting => 'import_settings',
			DepartmentShowSetting  => 'show_settings'  ,
		}.each do |setting_class, file_name|

			YAML.load_file("#{Rails.root}/config/#{file_name}.yml").each { |opt_array, data|
				data.each { |dep, bools|
					department = Department.where("name like '%#{dep.camelcase}%'").first
					if department.nil?
						Department.all.each { |d| 
							if d.name =~ /#{dep}/i then deparment = d; break; end
						}
					end
					if department.nil?
						dep = dict[dep]
						Department.all.each { |d| 
							if d.name =~ /#{dep}/i then deparment = d; break; end
						}
					end
					if department.nil?
						puts "[-] skipping #{dep}"
						next
					end
					puts "[+] processing bools for #{department.name}:"\
							+" #{[bools[0], bools[1]].to_s.sub(']','')}, ... ]"
					depset = setting_class.where(department_id: department.id).first
					depset.send("#{opt_array}=", bools)
					depset.save!
				}
			}

		end

		puts "-end- getoldsettings task"
	end
end
