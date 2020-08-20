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

ActiveRecord::Schema.define(version: 2020_08_20_142414) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "shipment_details", force: :cascade do |t|
    t.integer "status"
    t.text "description"
    t.bigint "shipment_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["shipment_id"], name: "index_shipment_details_on_shipment_id"
  end

  create_table "shipments", force: :cascade do |t|
    t.string "tracking_number"
    t.string "carrier"
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tracking_number"], name: "index_shipments_on_tracking_number"
  end

  add_foreign_key "shipment_details", "shipments"
end
