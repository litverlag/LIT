class CreateJoinTableBuecherReihen < ActiveRecord::Migration
  def change
  	create_join_table :buecher, :reihen
  end
end
