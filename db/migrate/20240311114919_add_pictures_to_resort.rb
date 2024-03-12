class AddPicturesToResort < ActiveRecord::Migration[7.0]
  def change
    add_column :resorts, :picture_url, :string
    add_column :resorts, :course_map_url, :string
  end
end
