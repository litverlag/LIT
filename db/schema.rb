# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170209183737) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "autoren", force: :cascade do |t|
    t.string   "fox_id"
    t.string   "anrede"
    t.string   "vorname"
    t.string   "name"
    t.string   "email"
    t.string   "str"
    t.string   "plz"
    t.string   "ort"
    t.string   "tel"
    t.string   "fax"
    t.string   "institut"
    t.boolean  "dienstadresse"
    t.string   "demail"
    t.string   "dstr"
    t.string   "dplz"
    t.string   "dort"
    t.string   "dtel"
    t.string   "dfax"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "autoren_buecher", id: false, force: :cascade do |t|
    t.integer "autor_id", null: false
    t.integer "buch_id",  null: false
  end

  create_table "autoren_reihen", id: false, force: :cascade do |t|
    t.integer "autor_id", null: false
    t.integer "reihe_id", null: false
  end

  create_table "autors", force: :cascade do |t|
    t.string   "fox_id"
    t.string   "anrede"
    t.string   "vorname"
    t.string   "name"
    t.string   "email"
    t.string   "str"
    t.string   "plz"
    t.string   "ort"
    t.string   "tel"
    t.string   "fax"
    t.string   "institut"
    t.string   "dienstadresse"
    t.string   "demail"
    t.string   "dstr"
    t.string   "dort"
    t.string   "dtel"
    t.string   "dfax"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "buecher", force: :cascade do |t|
    t.integer  "autor_id"
    t.integer  "lektor_id"
    t.integer  "gprod_id"
    t.string   "name"
    t.string   "isbn"
    t.string   "issn"
    t.text     "titel1"
    t.text     "titel2"
    t.text     "titel3"
    t.text     "utitel1"
    t.text     "utitel2"
    t.text     "utitel3"
    t.integer  "seiten"
    t.decimal  "preis",                precision: 6, scale: 2
    t.decimal  "spreis",               precision: 6, scale: 2
    t.boolean  "sammelband",                                   default: false
    t.date     "erscheinungsjahr"
    t.float    "gewicht"
    t.float    "volumen"
    t.string   "format_bezeichnung"
    t.string   "umschlag_bezeichnung"
    t.string   "papier_bezeichnung"
    t.string   "bindung_bezeichnung"
    t.string   "vier_farb"
    t.float    "rueckenstaerke"
    t.boolean  "klappentext",                                  default: true
    t.boolean  "eintrag_cip_seite"
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.string   "sw"
    t.string   "r_code"
  end

  create_table "buecher_reihen", id: false, force: :cascade do |t|
    t.integer "buch_id",  null: false
    t.integer "reihe_id", null: false
  end

  create_table "department_input_settings", force: :cascade do |t|
    t.integer  "department_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "gprods_options",  default: [],              array: true
    t.boolean  "buecher_options", default: [],              array: true
    t.boolean  "status_options",  default: [],              array: true
    t.index ["department_id"], name: "index_department_input_settings_on_department_id", using: :btree
  end

  create_table "department_show_settings", force: :cascade do |t|
    t.integer  "department_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "gprods_options",  default: [],              array: true
    t.boolean  "buecher_options", default: [],              array: true
    t.boolean  "status_options",  default: [],              array: true
    t.index ["department_id"], name: "index_department_show_settings_on_department_id", using: :btree
  end

  create_table "departments", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "department_show_settings_id"
    t.integer  "department_input_settings_id"
    t.index ["department_input_settings_id"], name: "index_departments_on_department_input_settings_id", using: :btree
    t.index ["department_show_settings_id"], name: "index_departments_on_department_show_settings_id", using: :btree
  end

  create_table "faecher", force: :cascade do |t|
    t.string   "name"
    t.string   "fox_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gprods", force: :cascade do |t|
    t.integer  "lektor_id"
    t.integer  "autor_id"
    t.date     "final_deadline"
    t.date     "zum_druck"
    t.date     "druck_deadline"
    t.date     "titelei_deadline"
    t.date     "satz_deadline"
    t.date     "preps_deadline"
    t.date     "offsch_deadline"
    t.date     "bildpr_deadline"
    t.date     "umschlag_deadline"
    t.date     "rg_deadline"
    t.date     "binderei_deadline"
    t.boolean  "projekt_abgeschlossen",              default: false
    t.string   "projekt_email_adresse"
    t.string   "projektname"
    t.integer  "auflage"
    t.date     "erscheinungsjahr"
    t.text     "kommentar_public"
    t.date     "manusskript_eingang_date"
    t.integer  "auflage_lektor"
    t.integer  "auflage_chef"
    t.integer  "gesicherte_abnahme"
    t.boolean  "satzproduktion",                     default: false
    t.boolean  "buchistfertig",                      default: false
    t.boolean  "externer_druck",                     default: false
    t.integer  "externer_druck_verschickt_von"
    t.date     "externer_druck_verschickt"
    t.boolean  "buchgedruckt",                       default: false
    t.text     "druck_bemerkungen"
    t.date     "pod_verschickt"
    t.string   "pod_meldung"
    t.text     "titelei_bemerkungen"
    t.string   "titelei_zusaetze"
    t.boolean  "titelei_extern",                     default: false
    t.date     "titelei_letzte_korrektur"
    t.date     "titelei_versand_datum_fuer_ueberpr"
    t.string   "titelei_versand_an_zur_ueberpf"
    t.date     "titelei_korrektur_date"
    t.date     "titelei_freigabe_date"
    t.text     "satz_bemerkungen"
    t.text     "preps_bemerkungen"
    t.string   "preps_betreuer"
    t.string   "druck_art"
    t.string   "muster_art"
    t.string   "muster_gedruckt"
    t.text     "preps_muster_bemerkungen"
    t.date     "preps_muster_date"
    t.text     "offsch_bemerkungen"
    t.string   "offsch_an_autor"
    t.string   "offsch_an_sch_mit_u"
    t.text     "bildpr_bemerkungen"
    t.text     "umschlag_bemerkungen"
    t.boolean  "umschlag_schutzumschlag",            default: false
    t.string   "umschlag_umschlagsbild"
    t.text     "rg_bemerkungen"
    t.string   "rg_rg_mail"
    t.date     "rg_versand_1"
    t.date     "rg_versand_2"
    t.boolean  "rg_bezahlt",                         default: false
    t.boolean  "rg_vf",                              default: false
    t.date     "binderei_eingang_datum"
    t.text     "binderei_bemerkungen"
    t.string   "prio"
    t.text     "lektor_bemerkungen_public"
    t.text     "lektor_bemerkungen_private"
    t.string   "dateibue"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "bilder"
    t.date     "externer_druck_deadline"
    t.date     "externer_druck_finished"
    t.text     "externer_druck_bemerkungen"
    t.text     "klappentextinfo"
    t.time     "satz_korrektur"
    t.string   "satz_bearbeiter"
    t.string   "satz_pfad"
    t.boolean  "beitraegerbriefversand"
    t.boolean  "diss"
    t.integer  "pflichtexemplare"
    t.boolean  "sonderdruck"
    t.integer  "sonderdrucke"
    t.string   "kaschierung"
    t.boolean  "gesperrt"
    t.date     "gesperrt_ende"
  end

  create_table "herausgaben_herausgeber", id: false, force: :cascade do |t|
    t.integer "buch_id"
    t.integer "autor_id"
    t.index ["autor_id"], name: "index_herausgaben_herausgeber_on_autor_id", using: :btree
    t.index ["buch_id"], name: "index_herausgaben_herausgeber_on_buch_id", using: :btree
  end

  create_table "lektoren", force: :cascade do |t|
    t.string   "name"
    t.string   "titel"
    t.string   "position"
    t.string   "emailkuerzel"
    t.string   "fox_name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "reihen", force: :cascade do |t|
    t.string   "name"
    t.string   "r_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "status_biblio_erf", force: :cascade do |t|
    t.integer "gprod_id"
    t.boolean "freigabe",    default: false
    t.date    "freigabe_at"
    t.string  "status"
    t.string  "updated_by"
    t.date    "updated_at"
  end

  create_table "status_bildpr", force: :cascade do |t|
    t.integer "gprod_id"
    t.string  "status"
    t.string  "updated_by"
    t.date    "updated_at"
  end

  create_table "status_binderei", force: :cascade do |t|
    t.integer "gprod_id"
    t.string  "status"
    t.string  "updated_by"
    t.date    "updated_at"
  end

  create_table "status_druck", force: :cascade do |t|
    t.integer "gprod_id"
    t.string  "status"
    t.string  "updated_by"
    t.date    "updated_at"
  end

  create_table "status_externer_druck", force: :cascade do |t|
    t.integer "gprod_id"
    t.string  "status"
    t.string  "updated_by"
    t.date    "updated_at"
  end

  create_table "status_final", force: :cascade do |t|
    t.integer "gprod_id"
    t.boolean "freigabe",    default: false
    t.date    "freigabe_at"
    t.string  "status"
    t.string  "updated_by"
    t.date    "updated_at"
  end

  create_table "status_offsch", force: :cascade do |t|
    t.integer "gprod_id"
    t.string  "status"
    t.string  "updated_by"
    t.date    "updated_at"
  end

  create_table "status_preps", force: :cascade do |t|
    t.integer "gprod_id"
    t.boolean "freigabe",    default: false
    t.date    "freigabe_at"
    t.string  "status"
    t.string  "updated_by"
    t.date    "updated_at"
  end

  create_table "status_rg", force: :cascade do |t|
    t.integer "gprod_id"
    t.string  "status"
    t.string  "updated_by"
    t.date    "updated_at"
  end

  create_table "status_satz", force: :cascade do |t|
    t.integer  "gprod_id"
    t.boolean  "freigabe",           default: false
    t.date     "freigabe_at"
    t.string   "status"
    t.string   "updated_by"
    t.date     "updated_at"
    t.datetime "eingang_at"
    t.datetime "deadline_soll"
    t.datetime "deadline_ist"
    t.datetime "statusaenderung_at"
    t.text     "kommentar"
    t.string   "pfad"
    t.integer  "bearbeiter_id"
  end

  create_table "status_titelei", force: :cascade do |t|
    t.integer "gprod_id"
    t.boolean "freigabe",    default: false
    t.date    "freigabe_at"
    t.string  "status"
    t.string  "updated_by"
    t.date    "updated_at"
  end

  create_table "status_umschl", force: :cascade do |t|
    t.integer "gprod_id"
    t.boolean "freigabe",    default: false
    t.date    "freigabe_at"
    t.string  "status"
    t.string  "updated_by"
    t.date    "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "vorname",                default: "", null: false
    t.string   "nachname",               default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "department"
    t.integer  "lektor_id"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

end
