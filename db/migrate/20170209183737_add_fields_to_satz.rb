class AddFieldsToSatz < ActiveRecord::Migration[5.0]
  def change
    add_column :status_satz, :eingang_at, :datetime
    add_column :status_satz, :deadline_soll, :datetime
    add_column :status_satz, :deadline_ist, :datetime
    add_column :status_satz, :statusaenderung_at, :datetime
    add_column :status_satz, :kommentar, :text
    add_column :status_satz, :pfad, :string
    add_column :status_satz, :bearbeiter_id, :integer
  end
end
