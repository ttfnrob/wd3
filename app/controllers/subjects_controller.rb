
class SubjectsController < ApplicationController
  def index
  end

  def show
  	@p ||= Subject.find_by_zooniverse_id(params[:zoo_id])
    n = params[:n] || 5
    threshold = params[:threshold] || 0
  	@tags = @p.clusterize( n.to_i, threshold.to_i )
  	@hex = {"diaryDate" => "#38674c", "person" => "#283f45", "place" => "#4ea4ad", "activity" => "#45815d", "weather" => "#00ffff"}
    @next_page = Subject.where('metadata.page_number' => @p.page_number + 1, 'group.zooniverse_id' => @p.group_id).first
    @prev_page = Subject.where('metadata.page_number' => @p.page_number - 1, 'group.zooniverse_id' => @p.group_id).first
  end

end
