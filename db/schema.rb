# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170515025745) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "campaigns", id: :string, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_duplicate_check"
  end

  create_table "duplicates", force: :cascade do |t|
    t.integer "entry1_id"
    t.integer "entry2_id"
    t.text "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "campaign_id", null: false
    t.index ["campaign_id"], name: "index_duplicates_on_campaign_id"
    t.index ["entry1_id", "entry2_id"], name: "index_duplicates_on_entry1_id_and_entry2_id", unique: true
  end

  create_table "entries", force: :cascade do |t|
    t.string "campaign_id"
    t.string "user_email"
    t.string "street"
    t.string "street_number"
    t.string "unit_number"
    t.string "people"
    t.string "contact"
    t.text "age_groups", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "last_visit"
    t.string "last_outcome"
    t.index ["campaign_id"], name: "index_entries_on_campaign_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.string "email"
    t.string "campaign_id"
    t.string "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_permissions_on_campaign_id"
    t.index ["email"], name: "index_permissions_on_email"
  end

  create_table "users", force: :cascade do |t|
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "oauth_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.index ["email"], name: "index_users_on_email"
  end

  create_table "visits", force: :cascade do |t|
    t.integer "entry_id"
    t.string "team"
    t.date "date"
    t.string "time"
    t.string "outcome"
    t.string "themes", default: [], array: true
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
