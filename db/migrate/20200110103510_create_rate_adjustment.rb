class CreateRateAdjustment < ActiveRecord::Migration[6.0]
  def change
    create_table :rate_adjustments do |t|
      t.integer :customer_id

      t.boolean :discount
      t.string :adjustment_type
      t.integer :value
      t.datetime :expire_date

      t.timestamps
    end
  end
end
