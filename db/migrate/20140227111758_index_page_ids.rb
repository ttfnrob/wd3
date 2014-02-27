class IndexPageIds < ActiveRecord::Migration
  def change
    add_index :activities, :page_id
    add_index :diary_dates, :page_id
    add_index :people, :page_id
    add_index :places, :page_id
    add_index :weathers, :page_id
  end
end
