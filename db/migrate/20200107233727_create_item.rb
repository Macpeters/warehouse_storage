class CreateItem < ActiveRecord::Migration[6.0]
  def change
    create_table :items do |t|
      t.string :name
      t.integer :length
      t.integer :height
      t.integer :width
      t.integer :value

      t.integer :storage_box_id

      t.timestamps
    end
  end
end
