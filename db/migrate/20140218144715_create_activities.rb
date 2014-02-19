class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :type
      t.string :page_id
      t.integer :x
      t.integer :y
      t.string :user_id

      t.timestamps
    end
  end
end
