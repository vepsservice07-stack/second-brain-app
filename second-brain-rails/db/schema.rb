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

ActiveRecord::Schema[8.1].define(version: 2025_12_10_053652) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "attachments", force: :cascade do |t|
    t.string "content_type"
    t.datetime "created_at", null: false
    t.bigint "file_size"
    t.string "filename"
    t.integer "note_id", null: false
    t.string "storage_url"
    t.datetime "updated_at", null: false
    t.index ["note_id"], name: "index_attachments_on_note_id"
  end

  create_table "causal_links", force: :cascade do |t|
    t.integer "cause_note_id", null: false
    t.text "context"
    t.datetime "created_at", null: false
    t.integer "effect_note_id", null: false
    t.decimal "strength", precision: 3, scale: 2, default: "1.0"
    t.datetime "updated_at", null: false
    t.index ["cause_note_id", "effect_note_id"], name: "index_causal_links_on_cause_note_id_and_effect_note_id", unique: true
    t.index ["cause_note_id"], name: "index_causal_links_on_cause_note_id"
    t.index ["effect_note_id"], name: "index_causal_links_on_effect_note_id"
  end

  create_table "cognitive_profiles", force: :cascade do |t|
    t.float "avg_confidence"
    t.float "avg_velocity"
    t.datetime "created_at", null: false
    t.json "patterns", default: {}, null: false
    t.integer "total_interactions_count", default: 0
    t.integer "total_notes_count", default: 0
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["patterns"], name: "index_cognitive_profiles_on_patterns"
    t.index ["user_id"], name: "index_cognitive_profiles_on_user_id"
  end

  create_table "note_links", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "link_type"
    t.bigint "source_note_id"
    t.bigint "target_note_id"
    t.datetime "updated_at", null: false
    t.index ["source_note_id", "target_note_id"], name: "index_note_links_on_source_note_id_and_target_note_id", unique: true
    t.index ["source_note_id"], name: "index_note_links_on_source_note_id"
    t.index ["target_note_id"], name: "index_note_links_on_target_note_id"
  end

  create_table "note_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "note_id", null: false
    t.integer "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["note_id", "tag_id"], name: "index_note_tags_on_note_id_and_tag_id", unique: true
    t.index ["note_id"], name: "index_note_tags_on_note_id"
    t.index ["tag_id"], name: "index_note_tags_on_tag_id"
  end

  create_table "notes", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.bigint "sequence_number"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.json "vector_clock"
    t.index ["created_at"], name: "index_notes_on_created_at"
    t.index ["deleted_at"], name: "index_notes_on_deleted_at"
    t.index ["sequence_number"], name: "index_notes_on_sequence_number", unique: true
    t.index ["title"], name: "index_notes_on_title"
    t.index ["user_id", "created_at"], name: "index_notes_on_user_id_and_created_at"
    t.index ["user_id", "updated_at"], name: "index_notes_on_user_id_and_updated_at"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "searchable_id"
    t.string "searchable_type"
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable"
  end

  create_table "rhythm_events", force: :cascade do |t|
    t.integer "bpm"
    t.datetime "created_at", null: false
    t.integer "duration_ms"
    t.string "event_type"
    t.integer "note_id", null: false
    t.string "proof_hash"
    t.bigint "sequence_number"
    t.bigint "timestamp_ms"
    t.datetime "updated_at", null: false
    t.json "vector_clock"
    t.index ["note_id", "sequence_number"], name: "index_rhythm_events_on_note_id_and_sequence_number"
    t.index ["note_id"], name: "index_rhythm_events_on_note_id"
    t.index ["sequence_number"], name: "index_rhythm_events_on_sequence_number"
  end

  create_table "tags", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attachments", "notes"
  add_foreign_key "causal_links", "notes", column: "cause_note_id"
  add_foreign_key "causal_links", "notes", column: "effect_note_id"
  add_foreign_key "cognitive_profiles", "users"
  add_foreign_key "note_tags", "notes"
  add_foreign_key "note_tags", "tags"
  add_foreign_key "rhythm_events", "notes"
end
