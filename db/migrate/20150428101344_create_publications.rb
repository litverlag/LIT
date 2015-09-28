class CreatePublications < ActiveRecord::Migration
  def change
    create_table :publications do |t|
      t.integer :autor_id
      t.integer :buch_id

      t.timestamps null: false
    end
  end
end
