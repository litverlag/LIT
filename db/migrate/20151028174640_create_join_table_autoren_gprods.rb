class CreateJoinTableAutorenGprods < ActiveRecord::Migration
  def change
  	create_join_table :autoren, :gprods
  end
end
