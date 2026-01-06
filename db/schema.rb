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

ActiveRecord::Schema[7.2].define(version: 2026_01_04_122000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "app_settings", force: :cascade do |t|
    t.boolean "token_expiry_enabled", default: false, null: false
    t.integer "default_access_mode", default: 0, null: false
    t.integer "global_access_mode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "calls", force: :cascade do |t|
    t.integer "table_id", null: false
    t.integer "kind", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kind"], name: "index_calls_on_kind"
    t.index ["status"], name: "index_calls_on_status"
    t.index ["table_id"], name: "index_calls_on_table_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_id"
    t.integer "sort_order", default: 0, null: false
    t.index ["parent_id", "name"], name: "index_categories_on_parent_id_and_name", unique: true
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["sort_order"], name: "index_categories_on_sort_order"
  end

  create_table "items", force: :cascade do |t|
    t.string "name", null: false
    t.integer "price", default: 0, null: false
    t.integer "category_id", null: false
    t.boolean "is_available", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_items_on_category_id"
    t.index ["is_available"], name: "index_items_on_is_available"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "item_id", null: false
    t.integer "quantity", default: 1, null: false
    t.integer "unit_price", null: false
    t.integer "status", default: 0, null: false
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_order_items_on_item_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["status"], name: "index_order_items_on_status"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "table_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "people_count"
    t.integer "cached_total", default: 0
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_orders_on_status"
    t.index ["table_id"], name: "index_orders_on_table_id"
  end

  create_table "payment_orders", force: :cascade do |t|
    t.integer "payment_id", null: false
    t.integer "order_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_payment_orders_on_order_id"
    t.index ["payment_id", "order_id"], name: "index_payment_orders_on_payment_id_and_order_id", unique: true
    t.index ["payment_id"], name: "index_payment_orders_on_payment_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "amount", null: false
    t.integer "discount_amount", default: 0, null: false
    t.integer "rounding_adjustment", default: 0, null: false
    t.integer "received_cash"
    t.integer "change"
    t.datetime "paid_at"
    t.integer "payment_method", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["paid_at"], name: "index_payments_on_paid_at"
    t.index ["status"], name: "index_payments_on_status"
  end

  create_table "tables", force: :cascade do |t|
    t.integer "number", null: false
    t.string "token", null: false
    t.integer "access_mode", default: 0, null: false
    t.boolean "active", default: false, null: false
    t.datetime "token_expires_at"
    t.string "pin_digest"
    t.datetime "pin_rotated_at"
    t.datetime "last_used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_tables_on_active"
    t.index ["number"], name: "index_tables_on_number", unique: true
    t.index ["token"], name: "index_tables_on_token", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "name", null: false
    t.integer "role", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "calls", "tables"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "items", "categories"
  add_foreign_key "order_items", "items"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "tables"
  add_foreign_key "payment_orders", "orders"
  add_foreign_key "payment_orders", "payments"
end
