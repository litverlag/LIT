class CreateStatusTitelei < ActiveRecord::Migration
  def change
    create_table :status_titelei do |t|
    	t.belongs_to :gprod

    	t.string :status
    	t.string :updated_by
    	t.date :updated_at

    end
  end
end
