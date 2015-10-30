class CreateJoinTableAutorenReihen < ActiveRecord::Migration
  def change
  	create_join_table :autoren, :reihen
  end
end
