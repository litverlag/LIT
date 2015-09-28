class AddCodeToReihen < ActiveRecord::Migration
  def change
    add_column :reihen, :r_code, :string
  end
end
