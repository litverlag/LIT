class CreateStatusOffsch < ActiveRecord::Migration
  def change
    create_table :status_offsch do |t|
    	t.belongs_to :gprod

    	t.string :status
    	t.string :updated_by
    	t.date :updatet_at

    end
  end
end
