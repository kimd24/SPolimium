class LegislatorsController < ApplicationController
  def index
    @legislators = Legislator.all
    @search = params["search"]
    if @search.present?
      @name = @search["name"]
      @legislators = Legislator.where("name ILIKE ?", "%#{@name}%")
    end
  end
end
