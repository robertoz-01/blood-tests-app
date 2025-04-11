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

ActiveRecord::Schema[8.0].define(version: 2025_04_11_072859) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "analyses", force: :cascade do |t|
    t.string "default_name", null: false
    t.string "other_names", default: [], array: true
    t.string "unit", null: false
    t.float "reference_lower"
    t.float "reference_upper"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "blood_checks", force: :cascade do |t|
    t.uuid "identifier", default: -> { "gen_random_uuid()" }, null: false
    t.date "check_date", null: false
    t.string "notes", default: "", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_blood_checks_on_user_id"
  end

  create_table "check_entries", force: :cascade do |t|
    t.bigint "blood_check_id", null: false
    t.bigint "analysis_id", null: false
    t.float "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["analysis_id"], name: "index_check_entries_on_analysis_id"
    t.index ["blood_check_id"], name: "index_check_entries_on_blood_check_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_name", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "blood_checks", "users"
  add_foreign_key "check_entries", "analyses"
  add_foreign_key "check_entries", "blood_checks"
  add_foreign_key "sessions", "users"
end
