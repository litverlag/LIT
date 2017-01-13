class AddSatzKorrBearbToGprod < ActiveRecord::Migration
  def change
    add_column :gprods, :satz_korrektur, :time
    add_column :gprods, :satz_bearbeiter, :string
  end
end
