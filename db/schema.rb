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

ActiveRecord::Schema.define(version: 20180808162318) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: ""
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
    t.datetime "deleted_at"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
    t.integer  "profile_id"
  end

  add_index "accounts", ["created_at"], name: "index_accounts_on_created_at", using: :btree
  add_index "accounts", ["deleted_at"], name: "index_accounts_on_deleted_at", using: :btree
  add_index "accounts", ["email"], name: "index_accounts_on_email", unique: true, using: :btree
  add_index "accounts", ["invitation_token"], name: "index_accounts_on_invitation_token", unique: true, using: :btree
  add_index "accounts", ["invitations_count"], name: "index_accounts_on_invitations_count", using: :btree
  add_index "accounts", ["invited_by_id"], name: "index_accounts_on_invited_by_id", using: :btree
  add_index "accounts", ["profile_id"], name: "index_accounts_on_profile_id", using: :btree
  add_index "accounts", ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true, using: :btree

  create_table "admins", force: true do |t|
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

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "campaing_page_posts", force: true do |t|
    t.integer  "social_post_id",   null: false
    t.integer  "campaing_page_id"
    t.string   "remote_id",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "campaing_page_posts", ["campaing_page_id"], name: "index_campaing_page_posts_on_campaing_page_id", using: :btree
  add_index "campaing_page_posts", ["social_post_id"], name: "index_campaing_page_posts_on_social_post_id", using: :btree

  create_table "campaing_pages", force: true do |t|
    t.string   "page_id"
    t.string   "access_token"
    t.string   "name"
    t.boolean  "publishing_on",    default: false
    t.integer  "oauth_account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "campaing_pages", ["oauth_account_id"], name: "index_campaing_pages_on_oauth_account_id", using: :btree

  create_table "coupons", force: true do |t|
    t.datetime "expired_at"
    t.decimal  "discount"
    t.string   "encrypted_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "credit_card_holders", force: true do |t|
    t.string   "state"
    t.string   "city"
    t.string   "zip"
    t.string   "address"
    t.string   "token"
    t.integer  "credit_card_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "profile_id"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "coupon_id"
    t.datetime "last_payment"
  end

  add_index "credit_card_holders", ["coupon_id"], name: "index_credit_card_holders_on_coupon_id", using: :btree
  add_index "credit_card_holders", ["credit_card_id"], name: "index_credit_card_holders_on_credit_card_id", using: :btree
  add_index "credit_card_holders", ["profile_id"], name: "index_credit_card_holders_on_profile_id", using: :btree

  create_table "credit_cards", force: true do |t|
    t.string   "last_four"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "exp_date"
  end

  create_table "de_accounts", force: true do |t|
    t.integer  "profile_id"
    t.string   "email"
    t.string   "account_full_name"
    t.string   "account_committee_name"
    t.string   "account_committee_id"
    t.string   "account_address"
    t.string   "account_city"
    t.string   "account_state"
    t.string   "account_zip"
    t.string   "account_recipient_kind"
    t.string   "account_district_or_locality"
    t.text     "account_campaign_disclaimer"
    t.integer  "contribution_limit"
    t.boolean  "show_employer_name",           default: true
    t.boolean  "show_employer_address",        default: false
    t.boolean  "show_occupation",              default: true
    t.string   "bank_account_name"
    t.string   "bank_routing_number"
    t.string   "bank_account_number"
    t.string   "contact_last_name"
    t.string   "contact_email"
    t.string   "contact_phone"
    t.string   "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_first_name"
    t.string   "contact_address"
    t.string   "contact_city"
    t.string   "contact_state"
    t.string   "contact_zip"
    t.string   "account_party"
    t.text     "agreements"
    t.boolean  "is_active_on_de",              default: false
    t.integer  "credit_card_id"
  end

  add_index "de_accounts", ["profile_id"], name: "index_de_accounts_on_profile_id", using: :btree

  create_table "domains", force: true do |t|
    t.string   "name"
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "internal"
  end

  create_table "donations", force: true do |t|
    t.string   "donor_first_name"
    t.string   "donor_middle_name"
    t.string   "donor_last_name"
    t.string   "donor_email"
    t.string   "donor_phone"
    t.string   "donor_address_1"
    t.string   "donor_address_2"
    t.string   "donor_city"
    t.string   "donor_state"
    t.string   "donor_zip"
    t.string   "employer_name"
    t.string   "employer_occupation"
    t.string   "employer_address"
    t.string   "employer_city"
    t.string   "employer_state"
    t.string   "employer_zip"
    t.decimal  "amount"
    t.string   "transaction_guid"
    t.string   "transaction_uri"
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "credit_card_id"
  end

  add_index "donations", ["profile_id"], name: "index_donations_on_profile_id", using: :btree

  create_table "events", force: true do |t|
    t.string   "title"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "time_zone",       default: "UTC"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.text     "description"
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "show_start_time", default: false
    t.boolean  "show_end_time"
    t.string   "link_text"
    t.text     "link_url"
  end

  add_index "events", ["profile_id"], name: "index_events_on_profile_id", using: :btree

  create_table "issue_categories", force: true do |t|
    t.string   "name"
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "issues", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "position"
    t.integer  "issue_category_id"
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "media", force: true do |t|
    t.text     "image"
    t.integer  "profile_id"
    t.text     "video_url"
    t.text     "video_embed_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  create_table "oauth_accounts", force: true do |t|
    t.integer  "profile_id"
    t.string   "uid"
    t.string   "provider"
    t.text     "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "oauth_expires_at"
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.string   "aasm_state",       default: "active"
  end

  add_index "oauth_accounts", ["aasm_state"], name: "index_oauth_accounts_on_aasm_state", using: :btree
  add_index "oauth_accounts", ["profile_id"], name: "index_oauth_accounts_on_profile_id", using: :btree
  add_index "oauth_accounts", ["uid"], name: "index_oauth_accounts_on_uid", using: :btree

  create_table "ownerships", force: true do |t|
    t.integer  "account_id"
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",       default: "AdminOwnership"
  end

  add_index "ownerships", ["account_id"], name: "index_ownerships_on_account_id", using: :btree
  add_index "ownerships", ["profile_id"], name: "index_ownerships_on_profile_id", using: :btree

  create_table "pages", force: true do |t|
    t.string   "name"
    t.text     "data"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["slug"], name: "index_pages_on_slug", using: :btree

  create_table "press_release_images", force: true do |t|
    t.integer "profile_id"
    t.text    "press_release_url"
    t.text    "image"
    t.boolean "active",            default: false
  end

  add_index "press_release_images", ["profile_id", "press_release_url"], name: "index_press_release_images_on_press_release_url", using: :btree

  create_table "press_releases", force: true do |t|
    t.integer  "profile_id"
    t.text     "title"
    t.text     "url"
    t.text     "page_title"
    t.boolean  "page_title_enabled",     default: true
    t.string   "page_date"
    t.boolean  "page_date_enabled",      default: true
    t.boolean  "page_thumbnail_enabled", default: true
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "press_releases", ["profile_id", "url"], name: "index_press_releases_on_profile_id_and_url", using: :btree
  add_index "press_releases", ["profile_id"], name: "index_press_releases_on_profile_id", using: :btree

  create_table "profiles", force: true do |t|
    t.string   "office"
    t.string   "tagline"
    t.string   "city"
    t.string   "state"
    t.string   "party_affiliation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "biography"
    t.boolean  "donation_notifications_on",          default: true
    t.boolean  "weekly_report_on",                   default: true
    t.boolean  "donations_on",                       default: true
    t.string   "phone"
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "events_on",                          default: false
    t.boolean  "press_on",                           default: false
    t.boolean  "questions_on",                       default: false
    t.boolean  "social_feed_on",                     default: false
    t.string   "address_1"
    t.string   "address_2"
    t.string   "campaign_website"
    t.string   "campaign_organization"
    t.string   "contact_city"
    t.string   "contact_state"
    t.boolean  "issues_on",                          default: false
    t.boolean  "media_on",                           default: false
    t.boolean  "biography_on",                       default: false
    t.boolean  "signup_notifications_on",            default: true
    t.integer  "photo_medium_id"
    t.integer  "hero_unit_medium_id"
    t.string   "district"
    t.string   "contact_zip"
    t.string   "campaign_organization_identifier"
    t.boolean  "facebook_on",                        default: false
    t.boolean  "twitter_on",                         default: false
    t.string   "background_image"
    t.integer  "background_image_medium_id"
    t.string   "campaign_disclaimer"
    t.text     "hero_unit"
    t.string   "photo"
    t.integer  "photo_cropping_width"
    t.integer  "photo_cropping_offset_x"
    t.integer  "photo_cropping_offset_y"
    t.string   "name"
    t.boolean  "hero_unit_on",                       default: false
    t.integer  "background_image_cropping_width"
    t.integer  "background_image_cropping_height"
    t.integer  "background_image_cropping_offset_y"
    t.integer  "background_image_cropping_offset_x"
    t.string   "type",                               default: "CandidateProfile"
    t.string   "theme",                              default: "theme-red"
    t.string   "upgrade_payment_token"
    t.string   "upgrade_cc_last_four"
    t.date     "upgrade_cc_exp_date"
    t.text     "upgrade_errors"
    t.boolean  "active",                             default: true
    t.integer  "owner_id"
    t.boolean  "suspended",                          default: false
    t.boolean  "premium_by_default",                 default: false
    t.string   "register_to_vote_url"
    t.boolean  "register_to_vote_on",                default: true
    t.string   "facebook_public_page_url"
  end

  add_index "profiles", ["owner_id"], name: "index_profiles_on_owner_id", using: :btree

  create_table "questions", force: true do |t|
    t.text     "text"
    t.integer  "user_id"
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "questions", ["profile_id"], name: "index_questions_on_profile_id", using: :btree
  add_index "questions", ["user_id"], name: "index_questions_on_user_id", using: :btree

  create_table "requests", force: true do |t|
    t.text     "data"
    t.integer  "requestable_id"
    t.string   "requestable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "requests", ["created_at"], name: "index_requests_on_created_at", using: :btree
  add_index "requests", ["requestable_type", "requestable_id"], name: "index_requests_on_requestable_type_and_requestable_id", using: :btree

  create_table "scores", force: true do |t|
    t.integer  "scorable_id"
    t.string   "scorable_type"
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scores", ["scorable_id"], name: "index_scores_on_scorable_id", using: :btree
  add_index "scores", ["scorable_type"], name: "index_scores_on_scorable_type", using: :btree

  create_table "social_posts", force: true do |t|
    t.integer  "profile_id"
    t.string   "provider"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "twitter_remote_id"
    t.string   "facebook_remote_id"
  end

  create_table "subscriptions", force: true do |t|
    t.integer  "profile_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscriptions", ["profile_id"], name: "index_subscriptions_on_profile_id", using: :btree
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "support_messages", force: true do |t|
    t.string   "subject"
    t.string   "email"
    t.string   "name"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.boolean  "subscribed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
