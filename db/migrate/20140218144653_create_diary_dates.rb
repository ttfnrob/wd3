class CreateDiaryDates < ActiveRecord::Migration
  def change
    create_table :diary_dates do |t|
      t.string :date
      t.string :page_id
      t.integer :x
      t.integer :y
      t.string :user_id

      t.timestamps
    end
  end
end
