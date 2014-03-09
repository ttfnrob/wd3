
class PagesController < ApplicationController
  def index
  end

  def show
  	@p = Subject.find_by_zooniverse_id(params[:zoo_id])
    n = params[:n] || 5
    threshold = params[:threshold] || 0
  	@tags = @p.clusterize( n.to_i, threshold.to_i )
  	@hex = {"diaryDate" => "#ff0000", "person" => "#ff00ff", "place" => "#0000ff", "activity" => "#00ff00", "weather" => "#00ffff"}
    @next_page = Subject.where('metadata.page_number' => @p.page_number + 1, 'group.zooniverse_id' => @p.group_id).first
    @prev_page = Subject.where('metadata.page_number' => @p.page_number - 1, 'group.zooniverse_id' => @p.group_id).first
  end

end
