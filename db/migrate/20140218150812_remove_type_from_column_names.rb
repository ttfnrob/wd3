class RemoveTypeFromColumnNames < ActiveRecord::Migration
  def up
  	rename_column :weathers, :type, :category
  	rename_column :activities, :type, :category
  end

  def down
  	rename_column :weathers, :category, :type
  	rename_column :activities, :category, :type
  end
end
