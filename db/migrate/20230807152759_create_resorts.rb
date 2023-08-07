class CreateResorts < ActiveRecord::Migration[7.0]
  def change
    create_table :resorts do |t|
      t.string :name
      t.string :prefecture
      t.string :town
      t.string :address
      t.integer :trial_length
      t.integer :longest_trial
      t.integer :skiable_terrain
      t.integer :number_of_trails
      t.integer :vertical_drop
      t.integer :lift
      t.integer :gondola
      t.integer :base_altitude
      t.integer :highest_altitude
      t.integer :steepest_gradient
      t.integer :difficulty_green
      t.integer :difficulty_red
      t.integer :difficulty_black
      t.boolean :terrain_park
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
