class CreateDocuments < ActiveRecord::Migration

  def change

    create_table :documents do |t|

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

      t.integer :word_count
      t.timestamps

    end

  end

end
