class CreateDocuments < ActiveRecord::Migration

  def change

    create_table :documents do |t|
      t.fetchable_attribs
      t.integer :word_count
      t.timestamps
    end

  end

end
