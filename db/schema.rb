# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_01_11_171402) do

  create_table "customers", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.integer "length"
    t.integer "height"
    t.integer "width"
    t.integer "value"
    t.integer "weight"
    t.integer "storage_box_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "rate_adjustment_thresholds", force: :cascade do |t|
    t.integer "rate_adjustment_id"
    t.integer "min_value"
    t.integer "max_value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "rate_adjustments", force: :cascade do |t|
    t.integer "adjustable_id"
    t.string "adjustable_type"
    t.string "adjustment_type"
    t.integer "value"
    t.datetime "expire_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "storage_boxes", force: :cascade do |t|
    t.integer "customer_id"
    t.float "storage_fee"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
