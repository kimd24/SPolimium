class AddIngredientsToCocktails < ActiveRecord::Migration[5.2]
  def change
    add_column :cocktails, :ingredients, :json
  end
end
