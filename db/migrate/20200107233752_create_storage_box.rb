class CreateStorageBox < ActiveRecord::Migration[6.0]
  def change
    create_table :storage_boxes do |t|
      t.integer :customer_id

      t.timestamps
    end
  end
end