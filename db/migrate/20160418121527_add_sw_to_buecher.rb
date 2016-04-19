class AddSwToBuecher < ActiveRecord::Migration
  def change
    add_column :buecher, :sw, :string
    add_column :buecher, :r_code, :string
    add_column :gprods, :bilder, :string
  end
end
