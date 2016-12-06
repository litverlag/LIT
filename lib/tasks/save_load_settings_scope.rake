namespace :db do

	desc "Save the current settings in config/default_[input/show]_settings."
	task save_settings: :environment do
		puts "[+] saving DepartmentShowSetting"
		DepartmentShowSetting.save_persistent 'default_show_settings'
		puts "[+] saving DepartmentInputSetting"
		DepartmentInputSetting.save_persistent 'default_input_settings'
	end

	desc "Load the current settings in config/default_[input/show]_settings."
	task load_settings: :environment do
		puts "[+] loading DepartmentShowSetting"
		DepartmentShowSetting.load_persistent 'default_show_settings'
		puts "[+] loading DepartmentInputSetting"
		DepartmentInputSetting.load_persistent 'default_input_settings'
	end

end
