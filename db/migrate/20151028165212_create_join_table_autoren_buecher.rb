class CreateJoinTableAutorenBuecher < ActiveRecord::Migration
  def change
  	create_join_table :autoren, :buecher
  end
end
