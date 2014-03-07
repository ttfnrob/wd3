
class PagesController < ApplicationController
  def index
  end

  def show
  	@p = Page.find(params[:zoo_id])
    n = params[:n] || 5
  	@tags = @p.clusterize( n.to_i )
  	@hex = {"diaryDate" => "#ff0000", "person" => "#ff00ff", "place" => "#0000ff", "activity" => "#00ff00", "weather" => "#00ffff"}
    @next_page = Page.find(:first, :conditions => ['page_number = ? and group_id = ?', @p.page_number + 1, @p.group_id])
    @prev_page = Page.find(:first, :conditions => ['page_number = ? and group_id = ?', @p.page_number - 1, @p.group_id])
  end

end
