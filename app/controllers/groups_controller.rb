class GroupsController < ApplicationController
  def index
    @diaries = Group.all
  end

  def show
    n = params[:n] || 5
    threshold = params[:threshold] || 0
  	@g ||= Group.find_by_zooniverse_id(params[:zoo_id])
    @tags = @g.tags n.to_i, threshold.to_i
  end
  
  def export
    n = params[:n] || 5
    threshold = params[:threshold] || 2
  	@g ||= Group.find_by_zooniverse_id(params[:zoo_id])
    @tags = @g.tags n.to_i, threshold.to_i
  end

end