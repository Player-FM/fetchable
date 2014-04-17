class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|

      # association
      t.string :fetchable_type
      t.integer :fetchable_id

      # source
      t.string :url

      # last fetch
      t.integer :status_code
      t.datetime :last_modified
      t.integer :size
      t.string :etag
      t.string :signature

      # the usual
      t.timestamps

    end
  end
end
