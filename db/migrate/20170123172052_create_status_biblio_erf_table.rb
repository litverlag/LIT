class CreateStatusBiblioErfTable < ActiveRecord::Migration
  def change
    create_table :status_biblio_erf, force: :cascade do |t|
      t.integer :gprod_id
      t.boolean :freigabe,    default: false
      t.date    :freigabe_at
      t.string  :status
      t.string  :updated_by
      t.date    :updated_at
    end
  end
end
