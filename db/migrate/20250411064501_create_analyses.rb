class CreateAnalyses < ActiveRecord::Migration[8.0]
  def change
    create_table :analyses do |t|
      t.string :default_name, null: false
      t.string :other_names, array: true, default: []
      t.string :unit, null: false
      t.float :reference_lower
      t.float :reference_upper
      t.timestamps
    end
  end
end
