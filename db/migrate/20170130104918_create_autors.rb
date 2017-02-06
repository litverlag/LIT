class CreateAutors < ActiveRecord::Migration[5.0]
  def change
    create_table :autors, force: :cascade do |t|
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
      t.string :dienstadresse
      t.string :demail
      t.string :dstr
      t.string :dort
      t.string :dtel
      t.string :dfax

      t.timestamps
    end
  end
end
