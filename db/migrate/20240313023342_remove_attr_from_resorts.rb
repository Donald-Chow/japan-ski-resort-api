class RemoveAttrFromResorts < ActiveRecord::Migration[7.0]
  def change
    remove_column :resorts, :terrain_park, :string
    remove_column :resorts, :skiable_terrain, :string
  end
end
