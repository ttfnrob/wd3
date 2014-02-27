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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140227111758) do

  create_table "activities", :force => true do |t|
    t.string   "category"
    t.string   "page_id"
    t.integer  "x"
    t.integer  "y"
    t.string   "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "activities", ["page_id"], :name => "index_activities_on_page_id"

  create_table "diary_dates", :force => true do |t|
    t.date     "date"
    t.string   "page_id"
    t.integer  "x"
    t.integer  "y"
    t.string   "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "note"
  end

  add_index "diary_dates", ["page_id"], :name => "index_diary_dates_on_page_id"

  create_table "pages", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "tna_id"
    t.integer  "page_number"
    t.string   "group_id"
  end

  create_table "people", :force => true do |t|
    t.string   "first"
    t.string   "surname"
    t.string   "rank"
    t.string   "reason"
    t.integer  "x"
    t.integer  "y"
    t.string   "page_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "user_id"
  end

  add_index "people", ["page_id"], :name => "index_people_on_page_id"

  create_table "places", :force => true do |t|
    t.string   "page_id"
    t.integer  "x"
    t.integer  "y"
    t.decimal  "lat",           :precision => 10, :scale => 7
    t.decimal  "lon",           :precision => 10, :scale => 7
    t.string   "geocoded_name"
    t.boolean  "at_location"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.string   "user_id"
    t.string   "typed_name"
    t.string   "note"
  end

  add_index "places", ["page_id"], :name => "index_places_on_page_id"

  create_table "users", :force => true do |t|
    t.string   "ip"
    t.integer  "classification_count"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "weathers", :force => true do |t|
    t.string   "category"
    t.string   "page_id"
    t.integer  "x"
    t.integer  "y"
    t.string   "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "weathers", ["page_id"], :name => "index_weathers_on_page_id"

end
