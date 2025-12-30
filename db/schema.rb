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

ActiveRecord::Schema[8.0].define(version: 2025_12_30_151138) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "kitchen_queues", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "order_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "priority", default: 0, null: false
    t.integer "estimated_cooking_time"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "store_id", null: false
    t.index ["order_id"], name: "index_kitchen_queues_on_order_id"
    t.index ["priority"], name: "index_kitchen_queues_on_priority"
    t.index ["started_at"], name: "index_kitchen_queues_on_started_at"
    t.index ["status"], name: "index_kitchen_queues_on_status"
    t.index ["store_id", "status"], name: "index_kitchen_queues_on_store_id_and_status"
    t.index ["store_id"], name: "index_kitchen_queues_on_store_id"
    t.index ["tenant_id", "status"], name: "index_kitchen_queues_on_tenant_id_and_status"
    t.index ["tenant_id"], name: "index_kitchen_queues_on_tenant_id"
  end

  create_table "menu_items", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "name", null: false
    t.text "description"
    t.integer "price", null: false
    t.string "category", null: false
    t.boolean "available", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "category_order", default: 0, null: false
    t.index ["available"], name: "index_menu_items_on_available"
    t.index ["category"], name: "index_menu_items_on_category"
    t.index ["category_order"], name: "index_menu_items_on_category_order"
    t.index ["tenant_id", "name"], name: "index_menu_items_on_tenant_id_and_name"
    t.index ["tenant_id"], name: "index_menu_items_on_tenant_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "menu_item_id", null: false
    t.integer "quantity", null: false
    t.integer "unit_price", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_item_id"], name: "index_order_items_on_menu_item_id"
    t.index ["order_id", "menu_item_id"], name: "index_order_items_on_order_id_and_menu_item_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "order_number", null: false
    t.integer "table_id"
    t.integer "status", default: 0, null: false
    t.integer "total_amount", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "store_id", null: false
    t.bigint "table_session_id"
    t.boolean "needs_printing", default: false
    t.datetime "printed_at"
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["store_id", "order_number"], name: "index_orders_on_store_id_and_order_number", unique: true
    t.index ["store_id", "status"], name: "index_orders_on_store_id_and_status"
    t.index ["store_id"], name: "index_orders_on_store_id"
    t.index ["table_id"], name: "index_orders_on_table_id"
    t.index ["table_session_id"], name: "index_orders_on_table_session_id"
    t.index ["tenant_id", "order_number"], name: "index_orders_on_tenant_id_and_order_number", unique: true
    t.index ["tenant_id"], name: "index_orders_on_tenant_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.integer "payment_method", null: false
    t.integer "amount", null: false
    t.integer "status", default: 0, null: false
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "table_session_id"
    t.index ["payment_method"], name: "index_payments_on_payment_method"
    t.index ["status"], name: "index_payments_on_status"
    t.index ["table_session_id"], name: "index_payments_on_table_session_id"
    t.index ["tenant_id", "created_at"], name: "index_payments_on_tenant_id_and_created_at"
    t.index ["tenant_id"], name: "index_payments_on_tenant_id"
  end

  create_table "print_logs", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "store_id", null: false
    t.bigint "order_id", null: false
    t.bigint "print_template_id"
    t.datetime "printed_at", null: false
    t.string "status", default: "success", null: false
    t.text "error_message"
    t.string "printer_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_print_logs_on_order_id"
    t.index ["print_template_id"], name: "index_print_logs_on_print_template_id"
    t.index ["printed_at"], name: "index_print_logs_on_printed_at"
    t.index ["status"], name: "index_print_logs_on_status"
    t.index ["store_id"], name: "index_print_logs_on_store_id"
    t.index ["tenant_id"], name: "index_print_logs_on_tenant_id"
  end

  create_table "print_templates", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "store_id"
    t.string "template_type", default: "kitchen_ticket", null: false
    t.string "name", null: false
    t.text "content", null: false
    t.boolean "is_active", default: true
    t.jsonb "settings", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_print_templates_on_store_id"
    t.index ["tenant_id", "template_type", "is_active"], name: "idx_on_tenant_id_template_type_is_active_55adf4752a"
    t.index ["tenant_id"], name: "index_print_templates_on_tenant_id"
  end

  create_table "staff_users", force: :cascade do |t|
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_staff_users_on_email", unique: true
    t.index ["role"], name: "index_staff_users_on_role"
  end

  create_table "stores", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "name", null: false
    t.string "address"
    t.string "phone"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_stores_on_active"
    t.index ["tenant_id", "name"], name: "index_stores_on_tenant_id_and_name", unique: true
    t.index ["tenant_id"], name: "index_stores_on_tenant_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.integer "plan", default: 0, null: false
    t.boolean "realtime_enabled", default: false, null: false
    t.boolean "polling_enabled", default: false, null: false
    t.integer "max_stores", default: 1, null: false
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "printing_enabled", default: false
    t.index ["expires_at"], name: "index_subscriptions_on_expires_at"
    t.index ["plan"], name: "index_subscriptions_on_plan"
    t.index ["tenant_id"], name: "index_subscriptions_on_tenant_id"
  end

  create_table "table_sessions", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "store_id", null: false
    t.integer "table_id", null: false
    t.integer "party_size"
    t.integer "status", default: 0, null: false
    t.datetime "started_at", null: false
    t.datetime "ended_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["started_at"], name: "index_table_sessions_on_started_at"
    t.index ["status"], name: "index_table_sessions_on_status"
    t.index ["store_id", "table_id", "status"], name: "index_table_sessions_on_store_table_status"
    t.index ["store_id"], name: "index_table_sessions_on_store_id"
    t.index ["table_id"], name: "index_table_sessions_on_table_id"
    t.index ["tenant_id"], name: "index_table_sessions_on_tenant_id"
  end

  create_table "tables", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.bigint "store_id", null: false
    t.string "number", null: false
    t.integer "capacity", default: 4
    t.integer "status", default: 0, null: false
    t.string "qr_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "position_x", default: 0.0
    t.float "position_y", default: 0.0
    t.string "shape", default: "square"
    t.index ["qr_code"], name: "index_tables_on_qr_code", unique: true, where: "(qr_code IS NOT NULL)"
    t.index ["store_id", "number"], name: "index_tables_on_store_id_and_number", unique: true
    t.index ["store_id"], name: "index_tables_on_store_id"
    t.index ["tenant_id"], name: "index_tables_on_tenant_id"
  end

  create_table "tags", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "name"], name: "index_tags_on_tenant_id_and_name", unique: true
    t.index ["tenant_id"], name: "index_tags_on_tenant_id"
  end

  create_table "tenant_user_tags", force: :cascade do |t|
    t.bigint "tenant_user_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_tenant_user_tags_on_tag_id"
    t.index ["tenant_user_id", "tag_id"], name: "index_tenant_user_tags_on_tenant_user_id_and_tag_id", unique: true
    t.index ["tenant_user_id"], name: "index_tenant_user_tags_on_tenant_user_id"
  end

  create_table "tenant_users", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role"], name: "index_tenant_users_on_role"
    t.index ["tenant_id", "email"], name: "index_tenant_users_on_tenant_id_and_email", unique: true
    t.index ["tenant_id"], name: "index_tenant_users_on_tenant_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.string "name", null: false
    t.string "subdomain", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subdomain"], name: "index_tenants_on_subdomain", unique: true
  end

  add_foreign_key "kitchen_queues", "orders"
  add_foreign_key "kitchen_queues", "stores"
  add_foreign_key "kitchen_queues", "tenants"
  add_foreign_key "menu_items", "tenants"
  add_foreign_key "order_items", "menu_items"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "stores"
  add_foreign_key "orders", "table_sessions"
  add_foreign_key "orders", "tenants"
  add_foreign_key "payments", "table_sessions"
  add_foreign_key "payments", "tenants"
  add_foreign_key "print_logs", "orders"
  add_foreign_key "print_logs", "print_templates"
  add_foreign_key "print_logs", "stores"
  add_foreign_key "print_logs", "tenants"
  add_foreign_key "print_templates", "stores"
  add_foreign_key "print_templates", "tenants"
  add_foreign_key "stores", "tenants"
  add_foreign_key "subscriptions", "tenants"
  add_foreign_key "table_sessions", "stores"
  add_foreign_key "table_sessions", "tenants"
  add_foreign_key "tables", "stores"
  add_foreign_key "tables", "tenants"
  add_foreign_key "tags", "tenants"
  add_foreign_key "tenant_user_tags", "tags"
  add_foreign_key "tenant_user_tags", "tenant_users"
  add_foreign_key "tenant_users", "tenants"
end
