# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)





Lektor.create(name:'Peter Schmidt',fox_name:'PS')
Lektor.create(name:'Annelise Muster',fox_name:'AM')
Lektor.create(name:'Fritz Hans',fox_name:'FH')
Lektor.create(name:'Thomas Gottschalk',fox_name:'TG')

#create Departments
Department.create!([{name:'Superadmin'},{name:'Umschlag'},{name:'Satz'},{name:'Titelei'},{name:'PrePs'},{name:'Rechnung'},{name:'Bildprüfung'},{name:'Pod'},{name:'Binderei'},{name:'Lektor'}])

#create default Admin User
admin = AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')
admin.departments = Department.all.select { |d| d.name == "Superadmin"}

