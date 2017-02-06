class CreateJoinTableHerausgabenHerausgeber < ActiveRecord::Migration  
    def change
      create_table :herausgaben_herausgeber, id: false do |t|
        t.integer :buch_id
        t.integer :autor_id
      end

      add_index :herausgaben_herausgeber, :buch_id
      add_index :herausgaben_herausgeber, :autor_id
    end
end
