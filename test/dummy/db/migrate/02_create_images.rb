class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.integer :resource_id
      t.string :url
      t.string :width
      t.string :height
      t.timestamps
    end
  end
end
