class AddVersandDeadlineKommentarToGprod < ActiveRecord::Migration
  def change
    add_column :gprods, :externer_druck_deadline, :date
    add_column :gprods, :externer_druck_finished, :date
    add_column :gprods, :externer_druck_bemerkungen, :text
  end
end
