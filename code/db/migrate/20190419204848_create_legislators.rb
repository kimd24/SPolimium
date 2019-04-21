class CreateLegislators < ActiveRecord::Migration[5.2]
  def change
    create_table :legislators do |t|
      t.string :name
      t.float "total_receipts"
      t.string "cycle"
      t.string "state"
      t.string "party"
      t.float "spent"
      t.float "cash_on_hand"
      t.float "debt"
      t.string "sourceOpenSecrets"
      t.json "candContributors"
      t.string :openSecretsID
      t.string :birthday
      t.string :gender
      t.float :total

      t.timestamps
    end
  end
end
