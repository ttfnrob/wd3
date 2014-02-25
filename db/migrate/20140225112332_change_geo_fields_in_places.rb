class ChangeGeoFieldsInPlaces < ActiveRecord::Migration
  def up
  	change_column :places, :lat, :decimal, :precision => 10, :scale => 7
  	change_column :places, :lon, :decimal, :precision => 10, :scale => 7
  end
end
