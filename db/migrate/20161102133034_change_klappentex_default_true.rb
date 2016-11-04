class ChangeKlappentexDefaultTrue < ActiveRecord::Migration
  def change
		change_column :buecher, :klappentext, :boolean, default: true
  end
end
