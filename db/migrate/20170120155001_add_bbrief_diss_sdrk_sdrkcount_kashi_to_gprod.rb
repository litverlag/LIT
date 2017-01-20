class AddBbriefDissSdrkSdrkcountKashiToGprod < ActiveRecord::Migration
  def change
    add_column :gprods, :beitraegerbriefversand, :boolean
    add_column :gprods, :diss, :boolean
    add_column :gprods, :pflichtexemplare, :integer
    add_column :gprods, :sonderdruck, :boolean
    add_column :gprods, :sonderdrucke, :integer
    add_column :gprods, :kaschierung, :string
  end
end
