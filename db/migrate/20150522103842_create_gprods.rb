class CreateGprods < ActiveRecord::Migration
  def change
    create_table :gprods do |t|

      #gejointe Attribute
      t.belongs_to :buch
      t.belongs_to :autor
      t.belongs_to :lektor

      #Nicht joined Attribute
      t.integer :auflage
      t.string :prio
      t.string :druck
      t.date :msein
      t.string :muster
      t.date :offsch_sollf
      t.date :einliste_sollf
      t.date :sreif_sollf
      t.date :lf_sollf
      t.date :preps_sollf
      t.date :tit_sollf
      t.date :rg_sollf
      t.string :rg_rg_mail
      t.date :rg_versand_1
      t.date :rg_versand_2
      t.boolean :rg_bezahlt
      t.boolean :rg_vf
      t.string :datei
      t.string :titelei
      t.string :satz
      t.string :sonder
      t.date :datum
      t.string :eintrag
      t.date :versand
      t.string :tit_an
      t.date :korrektur
      t.string :freigabe
      t.date :zum_druck
      t.string :tit_bemerkungen_1
      t.string :tit_bemerkungen_2
      t.string :bi
      t.string :vf
      t.string :preps_betreuer
      t.string :korr_betreuer
      t.string :preps_kommentar
      t.integer :tagesleistung
      t.string :email
      t.string :offsch_an_autor
      t.string :offsch_an_sch_mit_u
      t.boolean :is_archiv
      t.string :cover
      t.string :ebook_bemerkungen
      t.string :ftp
      t.string :webshop
      t.string :google
      t.string :afs
      t.string :luecken
      t.date :a1_dat
      t.date :a2_dat
      t.string :korr
      t.string :anmerkung
      t.date :pod_verschickt
      t.string :pod_meldung
      t.string :off
      t.string :ein_liste_status
      t.string :lf_status
      t.string :sreif_status
      t.string :um_status
      t.string :tit_status
      t.string :preps_status
      t.string :bi_status
      t.string :rg_status
      t.string :ebook_status
      t.string :korr_status
      t.string :pod_status
      t.date :um_sollf
      t.date :um_verschickt
      t.text :klapptext
      t.string :um_frei
      t.string :um_warten
      t.string  :rueckenfrei
      t.integer :gprod_id
      t.timestamps null: false
    end
  end
end
