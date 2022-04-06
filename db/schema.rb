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

ActiveRecord::Schema.define(version: 2018_12_02_125938) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string "trackable_type"
    t.bigint "trackable_id"
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "key"
    t.text "parameters"
    t.string "recipient_type"
    t.bigint "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["owner_type", "owner_id"], name: "index_activities_on_owner_type_and_owner_id"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["recipient_type", "recipient_id"], name: "index_activities_on_recipient_type_and_recipient_id"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable_type_and_trackable_id"
  end

  create_table "charges", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "project_id"
    t.float "amount"
    t.float "amount_for_merchant"
    t.string "stripe_charge"
    t.string "stripe_payout"
    t.datetime "payout_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "charge_succeeded_at"
    t.datetime "payout_paid_at"
    t.boolean "immediate", default: false
    t.float "stripe_fee"
    t.float "net_amount", default: 0.0
    t.string "source_brand"
    t.index ["project_id"], name: "index_charges_on_project_id"
    t.index ["user_id"], name: "index_charges_on_user_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.bigint "user_id"
    t.string "subject"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_contacts_on_user_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "user_id"
    t.string "stripe_customer"
    t.string "event_type"
    t.string "targetable_type"
    t.bigint "targetable_id"
    t.string "stripe_event"
    t.text "data"
    t.json "charge_ids", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["targetable_type", "targetable_id"], name: "index_events_on_targetable_type_and_targetable_id"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "url"
    t.string "imageable_type"
    t.bigint "imageable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id"
  end

  create_table "merchants", force: :cascade do |t|
    t.bigint "user_id"
    t.string "access_token"
    t.string "refresh_token"
    t.string "stripe_publishable_key"
    t.string "stripe_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_merchants_on_user_id"
  end

  create_table "message_users", force: :cascade do |t|
    t.bigint "message_id"
    t.bigint "user_id"
    t.boolean "unread", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_message_users_on_message_id"
    t.index ["user_id", "message_id"], name: "index_message_users_on_user_id_and_message_id", unique: true
    t.index ["user_id"], name: "index_message_users_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.bigint "project_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_messages_on_project_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "milestones", force: :cascade do |t|
    t.bigint "project_id"
    t.string "phase_name"
    t.text "suggestions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.float "phase_amount", default: 0.0
    t.index ["project_id"], name: "index_milestones_on_project_id"
  end

  create_table "project_homeowners", force: :cascade do |t|
    t.bigint "project_id"
    t.string "email"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_homeowners_on_project_id"
    t.index ["user_id"], name: "index_project_homeowners_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.string "client_name"
    t.string "address"
    t.string "duration"
    t.float "total_amount_due"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_charge"
    t.integer "status", default: 0
    t.float "fee_rate"
    t.boolean "service_fee_charged", default: false
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "user_devices", force: :cascade do |t|
    t.bigint "user_id"
    t.string "device_uid"
    t.integer "last_sign_in_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "push_token"
    t.index ["device_uid", "user_id"], name: "index_user_devices_on_device_uid_and_user_id", unique: true
    t.index ["user_id"], name: "index_user_devices_on_user_id"
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
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "full_name"
    t.string "avatar_path"
    t.integer "role"
    t.boolean "inactive", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_customer"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "charges", "projects"
  add_foreign_key "charges", "users"
  add_foreign_key "contacts", "users"
  add_foreign_key "events", "users"
  add_foreign_key "merchants", "users"
  add_foreign_key "message_users", "messages"
  add_foreign_key "message_users", "users"
  add_foreign_key "messages", "projects"
  add_foreign_key "messages", "users"
  add_foreign_key "milestones", "projects"
  add_foreign_key "project_homeowners", "projects"
  add_foreign_key "project_homeowners", "users"
  add_foreign_key "projects", "users"
  add_foreign_key "user_devices", "users"
end
