# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20200318123617) do

  create_table "users", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.text     "extras",          limit: 65535
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "name",            limit: 255
    t.string   "eye_type",        limit: 255
    t.string   "avatar",          limit: 255
    t.string   "medical_history", limit: 255
    t.string   "sex",             limit: 255
    t.integer  "IOP",             limit: 4
    t.integer  "age",             limit: 4
  end

  create_table "users_histories", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.text     "algo",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "avatar",     limit: 255
  end

end
