class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :id
      t.string :ip
      t.integer :classification_count

      t.timestamps
    end
  end
end
