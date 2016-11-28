ActiveAdmin.register DepartmentInputSetting do
	menu priority: 3
  config.filters = false

	controller do
    def permitted_params
      params.permit!
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
