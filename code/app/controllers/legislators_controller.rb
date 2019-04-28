# frozen_string_literal: true

# Project name: Polimium
# Description: Search engine for politician data
# Filename: legislators_controller.rb
# Description: controller actions for legislators
# Last modified on: 4/25/2019

class LegislatorsController < ApplicationController
  before_action only: [:show]

  # Function: index
  #
  # Parameters:
  # String: query for search
  #
  # Precondition: none
  # Postcondition: Returns all legislators or some legislators based on search

  def index
    @legislators = Legislator.all
    @search = params['search']
    if @search.present?
      @query = @search['query']
      @legislators = Legislator.where('name ILIKE ? OR state ILIKE ?', "%#{@query}%", "%#{@query}%")
    end
  end

  # Function: show
  #
  # Parameters:
  #
  # Precondition: index has been called
  # Postcondition: finds a specific legislator based on id

  def show
    @legislator = Legislator.find(params[:id])
  end
end
