class StatusExternerDruck < ActiveRecord::Migration
  def change
		create_table "status_externer_druck", force: :cascade do |t|
			t.integer "gprod_id"
			t.string  "status"
			t.string  "updated_by"
			t.date    "updated_at"
		end
  end
end
