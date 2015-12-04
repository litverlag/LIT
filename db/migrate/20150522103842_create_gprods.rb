class CreateGprods < ActiveRecord::Migration
  def change
    create_table :gprods do |t|

      #Association Attribute
      t.belongs_to :lektor
      t.belongs_to :autor


      #Deadlines (Datum)
        #Finale Daten
        t.date     "final_deadline"
        t.date     "zum_druck"
        #Druck
        t.date     "druck_deadline"
        #Titelei
        t.date     "titelei_deadline"
        #Satz
        t.date     "satz_deadline"
        #Pre Press
        t.date     "preps_deadline"
        #Offset / Schirm
        t.date     "offsch_deadline"
        #Bildprüfung
        t.date     "bildpr_deadline"
        #Umschlag
        t.date     "umschlag_deadline"
        #Buchhaltung
        t.date     "rg_deadline"
        #Binderei
        t.date "binderei_deadline"

      #Details
        #allg. Details
        t.boolean "projekt_abgeschlossen", default: false
        t.string   "projekt_email_adresse"
        t.string   "projektname"
        t.integer  "auflage"
        t.date     "erscheinungsjahr"
        t.text     "kommentar_public"
        #Satzproduktion?
        t.boolean "satzproduktion", default: false
        #Das Buch ist fertig
        t.boolean "buchistfertig", default: false
        #Geht das Buch in den externen Druck
        t.boolean  "externer_druck", default: false
        t.integer      "externer_druck_verschickt_von"
        t.date     "externer_druck_verschickt"
        #Wurde das Buch bereits gedruckt?(Änderungen sind nicht mehr zulässig)
        t.boolean "buchgedruckt", default: false

        #Druck
        t.text   "druck_bemerkungen"
        t.date     "pod_verschickt"
        t.string   "pod_meldung"
        #Titelei
        t.text   "titelei_bemerkungen"
        t.string "titelei_zusaetze"
        t.boolean "titelei_extern", default: false
        t.date "titlei_letzte_korrektur"
        #Satz
        t.text   "satz_bemerkungen"
        #Preps
        t.text   "preps_bemerkungen"
        t.string   "preps_betreuer"
        #Muster
        t.string  "muster_art"
        t.string  "muster_gedruckt"
        t.text  "preps_muster_bemerkungen"
        t.date   "preps_muster_date"
        #Offset / Schirm
        t.text   "offsch_bemerkungen"
        t.string   "offsch_an_autor"
        t.string   "offsch_an_sch_mit_u"
        #Bildprüfung
        t.text   "bildpr_bemerkungen"
        #Umschlag
        t.text   "umschlag_bemerkungen"
        t.boolean "umschlag_schutzumschlag", default: false
        t.string "umschlag_umschlagsbild"
        #Buchhaltung
        t.text   "rg_bemerkungen"
        t.string   "rg_rg_mail"
        t.date     "rg_versand_1"
        t.date     "rg_versand_2"
        t.boolean  "rg_bezahlt", default: false
        t.boolean  "rg_vf", default: false
        #Binderei
        t.text   "binderei_bemerkungen"
        #Lektor
        t.text   "lektor_bemerkungen_public"
        t.text   "lektor_bemerkungen_private"

        #TODO Eintrage ordnen ggf Löschen
        t.string   "prio"
        t.string   "datei"
        t.string   "sonder"
        t.string   "eintrag"
        t.date     "versand"
        t.date     "korrektur"
        t.string   "freigabe"
        t.boolean  "is_archiv", default: false
        t.string   "cover"
        t.string   "ebook_bemerkungen"
        t.string   "ftp"
        t.string   "webshop"
        t.string   "google"
        t.string   "afs"
        t.string   "luecken"
        t.date     "a1_dat"
        t.date     "a2_dat"
        t.string   "korr"
        t.string   "off"
        t.date     "um_verschickt"
        t.text     "klapptext"
        t.string   "um_frei"
        t.string   "um_warten"
        t.string   "rueckenfrei"
        t.datetime "created_at",          null: false
        t.datetime "updated_at",          null: false
    end
  end
end
