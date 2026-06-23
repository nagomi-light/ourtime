class AddNullFalseToUsersAndTeams < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :name, false
    change_column_null :users, :email, false
    
    change_column_null :teams, :name, false
  end
end
