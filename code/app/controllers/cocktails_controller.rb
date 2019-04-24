class CocktailsController < ApplicationController
  def index
    @cocktails = Cocktail.all
    @search = params["search"]
    if @search.present?
      @preparation = @search["preparation"]
      @cocktails = Cocktail.where("preparation ILIKE ? OR name ILIKE ?", "%#{@preparation}%", "%#{@preparation}%")
    end
  end
end
