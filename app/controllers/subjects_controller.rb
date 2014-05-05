
class SubjectsController < ApplicationController
  before_filter :authenticate
  
  def index
  end

  def show
  	@p ||= Subject.find_by_zooniverse_id(params[:zoo_id])
    @g ||= Group.find_by_zooniverse_id( @p.group_id )
    n = params[:n] || 5
    threshold = params[:threshold] || 0
  	tags = @p.clusterize( n.to_i ).select{|tag| tag["count"] >= threshold.to_i || (tag["page_type"] == "report" && tag["type"] == "person")}
    @tags = @p.timeline(tags)
    @tags = @tags.select{ |t| t['type'].in? params[:filter].split ',' } if params[:filter]
  	@hex = {"diaryDate" => "#38674c", "person" => "#283f45", "place" => "#4ea4ad", "activity" => "#45815d", "weather" => "#00ffff"}
    @next_page = Subject.where('metadata.page_number' => @p.page_number + 1, 'group.zooniverse_id' => @p.group_id).first
    @prev_page = Subject.where('metadata.page_number' => @p.page_number - 1, 'group.zooniverse_id' => @p.group_id).first
  end

end
