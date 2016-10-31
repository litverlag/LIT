# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the
# db with db:setup).

Department.create!([
	{name:'Superadmin'},{name:'Umschlag'},{name:'Satz'},{name:'Titelei'},
	{name:'PrePs'},{name:'Rechnung'},{name:'Bildprüfung'},{name:'Pod'},
	{name:'Binderei'},{name:'Lektor'}
])
Department.all.each do |d|
	ds = DepartmentShowSetting.create!(department_id: d.id)
	di = DepartmentInputSetting.create!(department_id: d.id)
	d.department_show_setting = ds
	d.department_input_setting = di
end

admin = AdminUser.create!(email: 'admin@example.com',
													password: 'cibcibcib', password_confirmation: 'cibcibcib')
admin.departments = Department.all.select { |d| d.name == "Superadmin"}


#Test:
Lektor.create!(name:'Guido Bellmann',fox_name:'bel',
							 emailkuerzel:'bellmann@lit-verlag.de')
Gprod.create!( :id => 1234, :projektname => 'testpj', 
							:projekt_email_adresse => 'sum@fu.lul', 
							:externer_druck => false)
Buch.create!( :name => 'testbuch', :isbn => '3-123-12345-3', :seiten => 200, 
						 :bindung_bezeichnung => 'klebe', 
						 :papier_bezeichnung => 'Offset 90g', 
						 :umschlag_bezeichnung => 'LaTeX', :gprod_id => 1234)
