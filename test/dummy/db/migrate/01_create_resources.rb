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
      t.string :fingerprint
      t.string :redirected_to

      # tracking
      t.integer :fail_count, default: 0, nil: false
      t.datetime :next_try_after
      t.datetime :fetched_at
      t.datetime :refetched_at
      t.datetime :failed_at
      t.datetime :tried_at

      # the usual
      t.timestamps

    end
  end
end
