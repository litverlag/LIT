class ChangeProjektEmailAdresseToArray < ActiveRecord::Migration
  def change
		change_column :gprods, :projekt_email_adresse, 'varchar  USING string_to_array(projekt_email_adresse)'
  end
end
