class AddNoteToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :note, :string
  end
end
