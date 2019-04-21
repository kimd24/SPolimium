class CreateLegislators < ActiveRecord::Migration[5.2]
  def change
    create_table :legislators do |t|
      t.string :name
      t.string :openSecretsID
      t.string :birthday
      t.string :gender
      t.float :total

      t.timestamps
    end
  end
end
