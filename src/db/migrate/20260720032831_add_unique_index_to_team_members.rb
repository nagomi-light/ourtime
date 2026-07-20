class AddUniqueIndexToTeamMembers < ActiveRecord::Migration[8.0]
  def change
    add_index :team_members,
              [:team_id, :user_id],
              unique: true
  end
end
