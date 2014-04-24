class CreateResources < ActiveRecord::Migration

  def change

    create_table :resources do |t|
      t.fetchable_attribs
      t.timestamps
    end

  end

end
