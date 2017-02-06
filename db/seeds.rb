# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Userlist = [{name: 'admin', mail: 'admin@lit-verlag.de', department: "admin"},
            {name: 'Hopf', mail: 'hopf@lit-verlag.de', department: "chef"},
            {name: 'Rainer', mail: 'rainer@lit-verlag.de', department: "lektor"},
            {name: 'Richter', mail: 'richter@lit-verlag.de', department: "lektor"},
            {name: 'Bellmann', mail: 'bellmann@lit-verlag.de', department: "lektor"},
            {name: 'Titelei', mail: 'titelei@lit-verlag.de', department: "titelei"},
            {name: 'Preps', mail: 'preps@lit-verlag.de', department: "preps"},
            {name: 'Druck', mail: 'druck@lit-verlag.de', department: "druck"},
            {name: 'Bindung', mail: 'bindung@lit-verlag.de', department: "bindung"},
            {name: 'Bindung', mail: 'bindung@lit-verlag.de', department: "umschlag"},
          ]
Userlist.each do |user|
  user = User.new({email: user[:mail], department: user[:department], nachname: user[:name], password: 'password', password_confirmation: 'password'})
  user.save
end
