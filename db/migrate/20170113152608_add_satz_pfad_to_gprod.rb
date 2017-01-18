class AddSatzPfadToGprod < ActiveRecord::Migration
  def change
    add_column :gprods, :satz_pfad, :string
  end
end
