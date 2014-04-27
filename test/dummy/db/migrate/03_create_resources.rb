# An example of a simple generic fetchable table which could be used for
# multiple media objects if we don't want to specialise it.
#
# We deliberately *don't* include the attribs here so we can subsequently test
# our updater helper will automatically add the necessary cols
class CreateResources < ActiveRecord::Migration

  def change

    create_table :resources do |t|
      t.fetchable_attribs
      t.timestamps
    end

  end

end
