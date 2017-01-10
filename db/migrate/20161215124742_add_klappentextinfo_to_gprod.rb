class AddKlappentextinfoToGprod < ActiveRecord::Migration
  def change
    add_column :gprods, :klappentextinfo, :text
  end
end
