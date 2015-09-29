# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Format.destroy_all
Format.create([{name:'15,3x9,3 (KleinBl)'}, {name:'16x11,5 (Pocket)'}, {name:'A5'}, {name:'22x16'}, {name:'23,5x16,2'}, {name:'22x21'}, {name:'24x17'}, {name:'A4'}])
Lektor.create(name:'Peter Schmidt',fox_name:'PS')