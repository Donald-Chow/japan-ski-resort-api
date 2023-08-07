class RenameTrialLengthToTrailLength < ActiveRecord::Migration[7.0]
  def change
    rename_column :resorts, :trial_length, :trail_length
  end
end
