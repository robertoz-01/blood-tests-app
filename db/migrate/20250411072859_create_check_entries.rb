class CreateCheckEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :check_entries do |t|
      t.uuid :identifier, null: false, default: -> { "gen_random_uuid()" }
      t.references :blood_check, null: false, foreign_key: true
      t.references :analysis, null: false, foreign_key: true
      t.float :value, null: false
      t.timestamps
    end
  end
end
