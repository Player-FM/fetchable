class UpdateResources < ActiveRecord::Migration

  def change
    add_fetchable_attribs(:resources)
  end

end
