class AddUsernameToPlace < ActiveRecord::Migration
  def change
    add_column :places, :user_id, :string
  end
end
