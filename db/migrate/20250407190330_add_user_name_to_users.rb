class AddUserNameToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :user_name, :string, null: true
    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
      UPDATE users
      SET user_name = email_address
        SQL
      end
    end
    change_column_null :users, :user_name, false
  end
end
