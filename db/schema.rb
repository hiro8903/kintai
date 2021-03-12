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

ActiveRecord::Schema.define(version: 20210312131542) do

  create_table "attendance_edit_requests", force: :cascade do |t|
    t.integer "attendance_id"
    t.integer "requester_id"
    t.integer "requested_id"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "state", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attendance_id"], name: "index_attendance_edit_requests_on_attendance_id"
    t.index ["requested_id"], name: "index_attendance_edit_requests_on_requested_id"
    t.index ["requester_id"], name: "index_attendance_edit_requests_on_requester_id"
  end

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "requested_id"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "monthly_requests", force: :cascade do |t|
    t.integer "requester_id"
    t.integer "requested_id"
    t.date "request_month"
    t.integer "state", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "check", default: 0
    t.index ["requested_id"], name: "index_monthly_requests_on_requested_id"
    t.index ["requester_id"], name: "index_monthly_requests_on_requester_id"
  end

  create_table "over_time_requests", force: :cascade do |t|
    t.integer "attendance_id"
    t.integer "requester_id"
    t.integer "requested_id"
    t.datetime "end_scheduled_at"
    t.string "content"
    t.integer "state", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attendance_id"], name: "index_over_time_requests_on_attendance_id"
    t.index ["requested_id"], name: "index_over_time_requests_on_requested_id"
    t.index ["requester_id"], name: "index_over_time_requests_on_requester_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.boolean "admin", default: false
    t.string "affiliation"
    t.datetime "basic_work_time", default: "2021-03-12 23:00:00"
    t.datetime "work_time", default: "2021-03-12 22:30:00"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remember_digest"
    t.time "designated_work_start_time", default: "2000-01-01 00:00:00"
    t.time "designated_work_end_time", default: "2000-01-01 09:00:00"
    t.boolean "superior", default: false
    t.integer "employee_number"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
