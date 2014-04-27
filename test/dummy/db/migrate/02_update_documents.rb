class UpdateDocuments < ActiveRecord::Migration

  def change
    add_fetchable_attribs(:documents)
  end

end
