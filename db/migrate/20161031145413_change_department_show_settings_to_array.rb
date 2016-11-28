class ChangeDepartmentShowSettingsToArray < ActiveRecord::Migration
  def change
		remove_column :department_show_settings, :gprods_options
		remove_column :department_show_settings, :buecher_options
		remove_column :department_show_settings, :status_options
		remove_column :department_input_settings, :gprods_options
		remove_column :department_input_settings, :buecher_options
		remove_column :department_input_settings, :status_options
		add_column :department_show_settings, :gprods_options, :boolean, array: true, default: []
		add_column :department_show_settings, :buecher_options, :boolean, array: true, default: []
		add_column :department_show_settings, :status_options, :boolean, array: true, default: []
		add_column :department_input_settings, :gprods_options, :boolean, array: true, default: []
		add_column :department_input_settings, :buecher_options, :boolean, array: true, default: []
		add_column :department_input_settings, :status_options, :boolean, array: true, default: []
  end
end
