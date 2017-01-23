class AddGesperrtGesperrtEndeToGprod < ActiveRecord::Migration
  def change
    add_column :gprods, :gesperrt, :boolean
    add_column :gprods, :gesperrt_ende, :date
  end
end
