class RemoveUserFromResort < ActiveRecord::Migration[7.0]
  def change
    remove_reference :resorts, :user, null: false, foreign_key: true
  end
end
