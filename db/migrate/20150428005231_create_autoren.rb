class CreateAutoren < ActiveRecord::Migration
  def change
    create_table :autoren do |t|
      t.string :fox_id
      t.string :anrede
      t.string :vorname
      t.string :name
      t.string :email
      t.string :str
      t.string :plz
      t.string :ort
      t.string :tel
      t.string :fax
      t.string :institut
      t.boolean :dienstadresse
      t.string :demail
      t.string :dstr
      t.string :dplz
      t.string :dort
      t.string :dtel
      t.string :dfax

      t.timestamps null: false
    end
  end
end
