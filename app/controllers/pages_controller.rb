
class PagesController < ApplicationController
  def index
  end

  def show
  	@p = Page.find(params[:zoo_id])
  	@tags = @p.clusterize
  	@hex = {"diary_date" => "#ff0000", "person" => "#ff00ff", "place" => "#0000ff", "activity" => "#00ff00", "weather" => "#00ffff"}
  end

end
