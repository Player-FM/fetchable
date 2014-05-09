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

ActiveRecord::Schema.define(version: 5) do

  create_table "documents", force: true do |t|
    t.integer  "word_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
    t.integer  "status_code"
    t.datetime "last_modified"
    t.integer  "size"
    t.string   "etag"
    t.string   "fingerprint"
    t.string   "redirect_chain"
    t.string   "permanent_redirect_url"
    t.string   "received_content_type"
    t.string   "inferred_content_type"
    t.integer  "fetch_fail_count",       default: 0
    t.datetime "fetch_tried_at"
    t.datetime "fetch_succeeded_at"
    t.datetime "fetch_changed_at"
    t.datetime "next_fetch_after",       default: '1970-01-01 00:00:00'
  end

  create_table "quotes", force: true do |t|
    t.string   "url"
    t.integer  "status_code"
    t.datetime "last_modified"
    t.integer  "size"
    t.string   "etag"
    t.string   "fingerprint"
    t.string   "redirect_chain"
    t.string   "permanent_redirect_url"
    t.string   "received_content_type"
    t.string   "inferred_content_type"
    t.integer  "fetch_fail_count",       default: 0
    t.datetime "fetch_tried_at"
    t.datetime "fetch_succeeded_at"
    t.datetime "fetch_changed_at"
    t.datetime "next_fetch_after",       default: '1970-01-01 00:00:00'
    t.string   "type"
    t.string   "composer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resources", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
    t.integer  "status_code"
    t.datetime "last_modified"
    t.integer  "size"
    t.string   "etag"
    t.string   "fingerprint"
    t.string   "redirect_chain"
    t.string   "permanent_redirect_url"
    t.string   "received_content_type"
    t.string   "inferred_content_type"
    t.integer  "fetch_fail_count",       default: 0
    t.datetime "fetch_tried_at"
    t.datetime "fetch_succeeded_at"
    t.datetime "fetch_changed_at"
    t.datetime "next_fetch_after",       default: '1970-01-01 00:00:00'
  end

end
