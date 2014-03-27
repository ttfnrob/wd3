class GroupsController < ApplicationController
  def index
    @diaries = Group.all
  end

  def show
    n = params[:n] || 5
    threshold = params[:threshold] || 0
  	@g ||= Group.find_by_zooniverse_id(params[:zoo_id])
  end
  
  def export
    n = params[:n] || 5
    threshold = params[:threshold] || 2
  	@g ||= Group.find_by_zooniverse_id(params[:zoo_id])
    @tags = @g.tags n.to_i, threshold.to_i
    @timeline = @g.timeline
    @timeline = @timeline.select{ |t| t['type'].in? params[:filter].split ',' } if params[:filter]
  end

end