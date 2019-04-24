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
   @legislator = Legislator.find(params[:id])
  end
  
  def new
    @legislator = Legislator.new
  end

  def edit
  end

  def create
    @legislator = Legislator.new(legislator_params)
    
    if @legislator.save
      redirect_to legislator_path(@legislator)
    else
      render :new
    end
  end
  
  def update
    if @legislator.update(legislator_params)
      redirect_to legislator_path(@legislator)
    else
      render :edit
    end
  end
  
  private
    def set_legislator
      @legislator = Legislator.find(params[:id])
    end
    
    def legislator_params
      legislator.require(:legislator).permit(:name)
    end
end
