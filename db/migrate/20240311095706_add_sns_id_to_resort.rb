class AddSnsIdToResort < ActiveRecord::Migration[7.0]
  def change
    add_column :resorts, :sns_id, :string
  end
end
