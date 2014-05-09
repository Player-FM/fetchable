# Example of STI usage
class CreateQuotes < ActiveRecord::Migration

  def change

    create_table :quotes do |t|
      t.fetchable_attribs
      t.string :type
      t.string :composer
      t.timestamps
    end

  end

end
