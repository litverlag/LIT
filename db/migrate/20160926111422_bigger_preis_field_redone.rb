class BiggerPreisFieldRedone < ActiveRecord::Migration
  def change
		change_column :buecher, :preis,  :decimal, {precision: 6, scale: 2}
		change_column :buecher, :spreis, :decimal, {precision: 6, scale: 2}
  end
end
