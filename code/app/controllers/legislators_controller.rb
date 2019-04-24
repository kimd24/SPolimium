class LegislatorsController < ApplicationController
  before_action only: [:show]

  def index
    @legislators = Legislator.all
    @search = params["search"]
    if @search.present?
      @name = @search["name"]
      @legislators = Legislator.where("name ILIKE ?", "%#{@name}%")
    end
  end

  def show
   # @legislator = Legislator.find(params[:name])
  end
end
