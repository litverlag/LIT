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
Department.create([{name:'superadmin'},{name:'Umschlag'},{name:'Satz'},{name:'Titelei'},{name:'PrePs'},{name:'Rechnung'},{name:'Bildprüfung'},{name:'Lektor'},{name:'Pod '},{name:'Binderei'}])



# Test-Gprods

=begin

Schema: CREATE TABLE "gprods" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar, "isbn" varchar(17), "auflage" integer, "prio" varchar, "druck" varchar, "msein" date,
"muster" varchar, "offsch_sollf" date, "einliste_sollf" date, "sreif_sollf" date, "lf_sollf" date, "preps_sollf" date, "tit_sollf" date, "rg_sollf" date, "rg_rg_mail" varchar, "rg_versand_1" date,
"rg_versand_2" date, "rg_bezahlt" boolean, "rg_vf" boolean, "datei" varchar, "reihe" varchar, "titelei" varchar, "papier" varchar, "gewicht" float, "volumen" float, "satz" varchar, "sonder" varchar,
"datum" date, "eintrag" varchar, "versand" date, "tit_an" varchar, "korrektur" date, "freigabe" varchar, "zum_druck" date, "erscheinungsjahr" date, "tit_bemerkungen_1" varchar, "tit_bemerkungen_2" varchar,
"lek" varchar, "seiten" integer, "format" varchar, "umschlag" varchar, "bi" varchar, "vf" varchar, "preps_betreuer" varchar, "korr_betreuer" varchar, "preps_kommentar" varchar, "tagesleistung" integer,
"email" varchar, "offsch_an_autor" varchar, "offsch_an_sch_mit_u" varchar, "is_archiv" boolean, "cover" varchar, "ebook_bemerkungen" varchar, "ftp" varchar, "webshop" varchar, "google" varchar,
"afs" varchar, "luecken" varchar, "a1_dat" date, "a2_dat" date, "korr" varchar, "anmerkung" varchar, "pod_verschickt" date, "pod_meldung" varchar, "off" varchar, "ein_liste_status" varchar,
"lf_status" varchar, "sreif_status" varchar, "um_status" varchar, "tit_status" varchar, "preps_status" varchar, "bi_status" varchar, "rg_status" varchar, "ebook_status" varchar, "korr_status" varchar,
"pod_status" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "um_sollf" date, "um_verschickt" date, "klapptext" text, "um_frei" varchar, "um_warten" varchar, "rueckenfrei" varchar);



(1..10).each do |a|
  Gprod.create({name: "Test#{a}Buch", msein: (Time.now + (15 + a).days),tit_sollf: (Time.now + (10 + a).days), um_sollf: (Time.now + (5 + a).days)})
end

=end

Gprod.create({name: "Foo"})