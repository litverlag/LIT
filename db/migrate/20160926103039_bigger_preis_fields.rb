class BiggerPreisFields < ActiveRecord::Migration
  def change
		change_column :buecher, :preis,  :decimal, {precision: 5, scale: 3}
		change_column :buecher, :spreis, :decimal, {precision: 5, scale: 3}
  end
end
