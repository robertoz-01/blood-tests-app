class AddUserNameToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :user_name, :string, null: true
    User.reset_column_information
    User.update_all('user_name = email_address')
    change_column_null :users, :user_name, false
  end
end
