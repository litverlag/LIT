class CreateDepartmentShowSettings < ActiveRecord::Migration
  def change
    create_table :department_show_settings do |t|
      t.references :department, index: true
      t.boolean :gprods_options, array: true
      t.boolean :buecher_options, array: true
      t.boolean :status_options, array: true

      t.timestamps null: false
    end
  end
end
