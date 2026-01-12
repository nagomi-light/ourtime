class ChangeTeamToNullableInEvents < ActiveRecord::Migration[8.0]
  def change
    change_column_null :events, :team_id, true
  end
end
