class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string :page_id
      t.integer :x
      t.integer :y
      t.decimal :lat
      t.decimal :lon
      t.string :geocoded_name
      t.boolean :at_location

      t.timestamps
    end
  end
end
