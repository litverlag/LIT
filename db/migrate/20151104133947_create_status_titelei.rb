class CreateStatusTitelei < ActiveRecord::Migration
  def change
    create_table :status_titelei, id: false do |t|
    	t.belongs_to :gprod

    	t.string :status
    	t.string :updated_by
    	t.date :updatet_at

    end
  end
end
