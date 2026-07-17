class RemoveOwnerFromTeams < ActiveRecord::Migration[8.0]
  def change
    remove_reference :teams, :owner, foreign_key: { to_table: :users }, index: true
  end
end
