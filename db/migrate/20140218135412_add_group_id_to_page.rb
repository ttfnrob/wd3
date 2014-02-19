class AddGroupIdToPage < ActiveRecord::Migration
  def change
    add_column :pages, :group_id, :string
  end
end
