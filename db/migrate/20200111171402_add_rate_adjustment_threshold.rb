class AddRateAdjustmentThreshold < ActiveRecord::Migration[6.0]
  def change
    create_table :rate_adjustment_thresholds do |t|
      t.integer :rate_adjustment_id

      t.integer :min_value
      t.integer :max_value

      t.timestamps
    end
  end
end
