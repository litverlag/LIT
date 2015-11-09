class CreateDepartments < ActiveRecord::Migration

	def migrate(direction)
		super
		Department.create!([{name:'Superadmin'},{name:'Umschlag'},{name:'Satz'},{name:'Titelei'},{name:'PrePs'},{name:'Rechnung'},{name:'Bildprüfung'},{name:'Pod'},{name:'Binderei'},{name:'Lektor'}])  if direction == :up
	end

  def change
    create_table :departments do |t|
      t.string :name
      t.timestamps null: false
    end
  end

end
