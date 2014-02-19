class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :first
      t.string :surname
      t.string :rank
      t.string :reason
      t.integer :x
      t.integer :y
      t.string :page_id

      t.timestamps
    end
  end
end
