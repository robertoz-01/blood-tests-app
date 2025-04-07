class CreateBloodChecks < ActiveRecord::Migration[8.0]
  def change
    create_table :blood_checks do |t|
      t.uuid :identifier, default: 'gen_random_uuid()', null: false
      t.date :check_date, null: false
      t.string :notes, default: '', null: false
      t.references :user, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
