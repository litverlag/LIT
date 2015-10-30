# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

AdminUser.create([{id: 1},{email: 'admin@example.com'},{encrypted_password: '$2a$10$2u0t4aRB0zAoPMNZWGhnC.zJENSSoo2BLOW08gmKXwcNiXL2nL6oq'}])



Format.destroy_all
Format.create([{name:'15,3x9,3 (KleinBl)'}, {name:'16x11,5 (Pocket)'}, {name:'A5'}, {name:'22x16'}, {name:'23,5x16,2'}, {name:'22x21'}, {name:'24x17'}, {name:'A4'}])



Lektor.create(name:'Peter Schmidt',fox_name:'PS')
Lektor.create(name:'Annelise Muster',fox_name:'AM')
Lektor.create(name:'Fritz Hans',fox_name:'FH')
Lektor.create(name:'Thomas Gottschalk',fox_name:'TG')

#Wichtig für das erstellen der Abteilungen
Department.create([{name:'superadmin'},{name:'Umschlag'},{name:'Satz'},{name:'Titelei'},{name:'PrePs'},{name:'Rechnung'},{name:'Bildprüfung'},{name:'Lektor'},{name:'Pod '},{name:'Binderei'}])


