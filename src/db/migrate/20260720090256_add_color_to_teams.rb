class AddColorToTeams < ActiveRecord::Migration[8.0]
  def change
    add_column :teams, :color, :string
  end
end
