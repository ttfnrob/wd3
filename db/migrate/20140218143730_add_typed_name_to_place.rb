class AddTypedNameToPlace < ActiveRecord::Migration
  def change
    add_column :places, :typed_name, :string
  end
end
