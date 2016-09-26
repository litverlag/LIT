class BiggerPreisFields < ActiveRecord::Migration
  def change
		change_column :buecher, :preis,  :decimal, {precision: 4, scale: 4}
		change_column :buecher, :spreis, :decimal, {precision: 4, scale: 4}
  end
end
