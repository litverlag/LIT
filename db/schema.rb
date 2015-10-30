# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151028175323) do

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true

  create_table "admin_users_departments", id: false, force: :cascade do |t|
    t.integer "admin_user_id", null: false
    t.integer "department_id", null: false
  end

  create_table "admin_users_lektoren", id: false, force: :cascade do |t|
    t.integer "admin_user_id", null: false
    t.integer "lektor_id",     null: false
  end

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
    t.integer  "gprod_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "autoren_buecher", id: false, force: :cascade do |t|
    t.integer "autor_id", null: false
    t.integer "buch_id",  null: false
  end

  create_table "autoren_gprods", id: false, force: :cascade do |t|
    t.integer "autor_id", null: false
    t.integer "gprod_id", null: false
  end

  create_table "autoren_reihen", id: false, force: :cascade do |t|
    t.integer "autor_id", null: false
    t.integer "reihe_id", null: false
  end

  create_table "bindungen", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "buecher", force: :cascade do |t|
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
    t.decimal  "preis",            precision: 4, scale: 2
    t.decimal  "spreis",           precision: 4, scale: 2
    t.boolean  "sammelband"
    t.date     "erscheinungsjahr"
    t.float    "gewicht"
    t.float    "volumen"
    t.integer  "format_id"
    t.integer  "bindung_id"
    t.integer  "papier_id"
    t.integer  "umschlag_id"
    t.integer  "autor_id"
    t.integer  "lektor_id"
    t.integer  "gprod_id"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  create_table "buecher_reihen", id: false, force: :cascade do |t|
    t.integer "buch_id",  null: false
    t.integer "reihe_id", null: false
  end

  create_table "departments", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "faecher", force: :cascade do |t|
    t.string   "name"
    t.string   "fox_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "formate", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gprods", force: :cascade do |t|
    t.integer  "buch_id"
    t.integer  "autor_id"
    t.integer  "lektor_id"
    t.integer  "auflage"
    t.string   "prio"
    t.string   "druck"
    t.date     "msein"
    t.string   "muster"
    t.date     "offsch_sollf"
    t.date     "einliste_sollf"
    t.date     "sreif_sollf"
    t.date     "lf_sollf"
    t.date     "preps_sollf"
    t.date     "tit_sollf"
    t.date     "rg_sollf"
    t.string   "rg_rg_mail"
    t.date     "rg_versand_1"
    t.date     "rg_versand_2"
    t.boolean  "rg_bezahlt"
    t.boolean  "rg_vf"
    t.string   "datei"
    t.string   "titelei"
    t.string   "satz"
    t.string   "sonder"
    t.date     "datum"
    t.string   "eintrag"
    t.date     "versand"
    t.string   "tit_an"
    t.date     "korrektur"
    t.string   "freigabe"
    t.date     "zum_druck"
    t.string   "tit_bemerkungen_1"
    t.string   "tit_bemerkungen_2"
    t.string   "bi"
    t.string   "vf"
    t.string   "preps_betreuer"
    t.string   "korr_betreuer"
    t.string   "preps_kommentar"
    t.integer  "tagesleistung"
    t.string   "email"
    t.string   "offsch_an_autor"
    t.string   "offsch_an_sch_mit_u"
    t.boolean  "is_archiv"
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
    t.string   "anmerkung"
    t.date     "pod_verschickt"
    t.string   "pod_meldung"
    t.string   "off"
    t.string   "ein_liste_status"
    t.string   "lf_status"
    t.string   "sreif_status"
    t.string   "um_status"
    t.string   "tit_status"
    t.string   "preps_status"
    t.string   "bi_status"
    t.string   "rg_status"
    t.string   "ebook_status"
    t.string   "korr_status"
    t.string   "pod_status"
    t.date     "um_sollf"
    t.date     "um_verschickt"
    t.text     "klapptext"
    t.string   "um_frei"
    t.string   "um_warten"
    t.string   "rueckenfrei"
    t.integer  "gprod_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "lektoren", force: :cascade do |t|
    t.string   "name"
    t.string   "fox_name"
    t.integer  "gprod_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "papiere", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reihen", force: :cascade do |t|
    t.string   "name"
    t.string   "r_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reihen_hg_zuordnungen", force: :cascade do |t|
    t.integer  "reihe_id"
    t.integer  "autor_id"
    t.integer  "frei_ex"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reihen_zuordnungen", force: :cascade do |t|
    t.integer  "buch_id"
    t.integer  "reihe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "umschlaege", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
