class AddInputSettingsToDepartments < ActiveRecord::Migration
  def change
		add_reference :departments, :department_input_settings, index: true
    add_foreign_key :departments, :department_input_settings, 
			name: 'input_settings', on_delete: :cascade
  end
end
