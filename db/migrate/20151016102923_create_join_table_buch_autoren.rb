class CreateJoinTableBuchAutoren < ActiveRecord::Migration
  def change
    create_join_table :Autoren, :Buecher do |t|
       t.index [:autor_id, :buch_id]
       t.index [:buch_id, :autor_id]
    end
  end
end
