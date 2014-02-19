
class PagesController < ApplicationController
  def index
  end

  def show
  	@p = Page.find(params[:zoo_id])
  end
end
