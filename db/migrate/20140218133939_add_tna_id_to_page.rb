class AddTnaIdToPage < ActiveRecord::Migration
  def change
    add_column :pages, :tna_id, :string
  end
end
