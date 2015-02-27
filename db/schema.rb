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

ActiveRecord::Schema.define(version: 20150226233614) do

  create_table "approvals", force: :cascade do |t|
    t.integer  "status"
    t.integer  "document_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "document_revisions", force: :cascade do |t|
    t.integer  "major_version"
    t.integer  "minor_version"
    t.string   "content"
    t.string   "change_control"
    t.integer  "document_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "document_revisions", ["document_id"], name: "index_document_revisions_on_document_id"

  create_table "document_tags", force: :cascade do |t|
    t.string   "name"
    t.integer  "organisation_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "document_types", force: :cascade do |t|
    t.string   "name"
    t.integer  "organisation_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "documents", force: :cascade do |t|
    t.string   "title"
    t.integer  "status"
    t.string   "content"
    t.boolean  "assigned_to_all"
    t.integer  "user_id"
    t.integer  "organisation_id"
    t.integer  "document_type_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "doc_file_name"
    t.string   "doc_content_type"
    t.integer  "doc_file_size"
    t.datetime "doc_updated_at"
    t.string   "major_version"
    t.string   "minor_version"
    t.boolean  "do_update"
  end

  create_table "organisation_tags", force: :cascade do |t|
    t.integer  "document_id"
    t.integer  "document_tag_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "organisation_users", force: :cascade do |t|
    t.boolean  "accepted"
    t.integer  "user_type"
    t.integer  "user_id"
    t.integer  "organisation_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "inviter_id"
  end

  create_table "organisations", force: :cascade do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pending_users", force: :cascade do |t|
    t.string   "email"
    t.string   "user_type"
    t.integer  "organisation_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "inviter_id"
  end

  create_table "readers", force: :cascade do |t|
    t.integer  "document_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "readers", ["document_id"], name: "index_readers_on_document_id"
  add_index "readers", ["user_id"], name: "index_readers_on_user_id"

  create_table "reviews", force: :cascade do |t|
    t.integer  "status"
    t.integer  "document_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "doc_file_name"
    t.string   "doc_content_type"
    t.integer  "doc_file_size"
    t.datetime "doc_updated_at"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
