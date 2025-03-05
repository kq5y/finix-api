# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_03_05_151758) do
  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "expenditures", force: :cascade do |t|
    t.decimal "amount"
    t.text "description"
    t.date "date"
    t.integer "category_id", null: false
    t.integer "location_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "payment_method_id", null: false
    t.index ["category_id"], name: "index_expenditures_on_category_id"
    t.index ["location_id"], name: "index_expenditures_on_location_id"
    t.index ["payment_method_id"], name: "index_expenditures_on_payment_method_id"
    t.index ["user_id"], name: "index_expenditures_on_user_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_locations_on_user_id"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.string "name"
    t.string "payment_type"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_payment_methods_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "uid"
    t.string "username"
    t.string "avatar"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "categories", "users"
  add_foreign_key "expenditures", "categories"
  add_foreign_key "expenditures", "locations"
  add_foreign_key "expenditures", "payment_methods"
  add_foreign_key "expenditures", "users"
  add_foreign_key "locations", "users"
  add_foreign_key "payment_methods", "users"
end
