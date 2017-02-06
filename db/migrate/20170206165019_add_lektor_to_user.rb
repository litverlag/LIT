class AddLektorToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :lektor_id, :integer, foreign_key: true
  end
end
