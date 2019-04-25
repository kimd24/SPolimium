# Project name: Polimium
# Description: Search engine for politicans
# Filename: schema.rb
# Description: outlines the schema of the database
# Last modified on: 4/25/2019

ActiveRecord::Schema.define(version: 2019_04_19_204848) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "legislators", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.string "openSecretsID"
    t.date "birthday"
    t.string "gender"
    t.float "total_receipts"
    t.string "cycle"
    t.string "state"
    t.string "party"
    t.float "spent"
    t.float "cash_on_hand"
    t.float "debt"
    t.string "sourceOpenSecrets"
    t.json "candContributors"
    t.json "candIndustries"
    t.json "positions"
    t.string "contact_form"
    t.string "address"
    t.string "phone"

    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
