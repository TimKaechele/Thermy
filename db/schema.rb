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

ActiveRecord::Schema.define(version: 2020_09_01_084847) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "thermostat_readings", force: :cascade do |t|
    t.bigint "thermostat_id", null: false
    t.integer "sequence_number", null: false
    t.float "temperature", null: false
    t.float "humidity", null: false
    t.float "battery_charge", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["thermostat_id", "sequence_number"], name: "index_thermostat_readings_on_thermostat_id_and_sequence_number", unique: true
    t.index ["thermostat_id"], name: "index_thermostat_readings_on_thermostat_id"
  end

  create_table "thermostats", force: :cascade do |t|
    t.string "household_token", null: false
    t.string "street", null: false
    t.string "zip_code", null: false
    t.string "city", null: false
    t.string "country", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["household_token"], name: "index_thermostats_on_household_token", unique: true
  end

  add_foreign_key "thermostat_readings", "thermostats", on_update: :cascade, on_delete: :cascade
end
