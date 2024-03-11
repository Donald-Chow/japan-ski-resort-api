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

ActiveRecord::Schema[7.0].define(version: 2024_03_11_114919) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "resorts", force: :cascade do |t|
    t.string "name"
    t.string "prefecture"
    t.string "town"
    t.string "address"
    t.integer "trail_length"
    t.integer "longest_trial"
    t.integer "skiable_terrain"
    t.integer "number_of_trails"
    t.integer "vertical_drop"
    t.integer "lift"
    t.integer "gondola"
    t.integer "base_altitude"
    t.integer "highest_altitude"
    t.integer "steepest_gradient"
    t.integer "difficulty_green"
    t.integer "difficulty_red"
    t.integer "difficulty_black"
    t.boolean "terrain_park"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sns_id"
    t.string "picture_url"
    t.string "course_map_url"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.string "authentication_token", limit: 30
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
