class AddShowSettingsToDepartments < ActiveRecord::Migration
  def change
    add_reference :departments, :department_show_settings, index: true
    add_foreign_key :departments, :department_show_settings,
			name: 'show_settings', on_delete: :cascade
  end
end
