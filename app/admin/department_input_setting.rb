ActiveAdmin.register DepartmentInputSetting do
	menu priority: 3
  config.filters = false
  #actions :edit

	controller do

    def permitted_params
      params.permit!
    end

		def update
      to_update = DepartmentInputSetting.find(permitted_params[:id])
			begin
				to_update.update!
			rescue ActiveRecord::RecordInvalid
				redirect_to "/admin/department_input_settings/#{to_update.id}/edit"
				flash[:alert] = I18n.t 'flash_notice.revised_failure.new_projekt_invalid'
				return
			end
			#redirect_to "/admin/department_input_settings/#{to_update.id}/show"
		end

		def save_persistent
			File.open("#{Rails.root}/config/default_input_settings.yml", 'w') do |file|
				InputSettings.instance.all('gprod')
				data = DepartmentInputSetting.all.map{|s| s}
			end
		end

		def load_persistent
			yam = YAML.load_file("#{Rails.root}/config/default_input_settings.yml")
			yam["names"].each do |name_of_option|
				yam["options"].each do |type_of_option|
					if name_of_option.first == type_of_option.first
						if !name_of_option.second.nil?
							ALL[type_of_option.first]=make_options_hash(type_of_option.second,name_of_option.second)
						end
						if name_of_option.second.nil?
						ALL[type_of_option.first] = make_options_hash(type_of_option.second,nil)
						end
					end
				end
			end
		end

	end

	index do
		column 'Department Settings' do |c|
			link_to(Department.where(id: c.id).first.name , "/admin/department_input_settings/#{c.id}")\
							rescue link_to('..', "/admin/department_input_settings/#{c.id}")
		end
	end

	form do |f|
		gprods = InputSettings.instance.all('gprods').sort
		buecher = InputSettings.instance.all('buecher').sort
		status = InputSettings.instance.all('status').sort

		f.actions

		f.inputs 'gprods' do
			gprods.each {|option|
				f.input option.to_sym, as: :boolean
			}
		end
		f.inputs 'buecher' do
			buecher.each {|option|
				f.input option.to_sym, as: :boolean
			}
		end
		f.inputs 'status' do
			status.each {|option|
				next if option == :status_externer_druck
				f.input option.to_s.gsub('_','').to_sym, as: :boolean
			}
		end
	end

end
