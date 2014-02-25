class AddNoteToDiaryDates < ActiveRecord::Migration
  def change
    add_column :diary_dates, :note, :string
  end
end
