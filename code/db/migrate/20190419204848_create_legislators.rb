class CreateLegislators < ActiveRecord::Migration[5.2]
  def change
    create_table :legislators do |t|
      t.string :name
      t.string :title
      t.float :total_receipts
      t.string :cycle
      t.string :state
      t.string :party
      t.float :spent
      t.float :cash_on_hand
      t.float :debt
      t.string :sourceOpenSecrets
      t.json :candContributors
      t.string :candIndustries
      t.json :positions
      t.string :openSecretsID
      t.date :birthday
      t.string :gender
      t.string :contact_form
      t.string :address
      t.string :phone

      t.timestamps
    end
  end
end
