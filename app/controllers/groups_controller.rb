class GroupsController < ApplicationController
  def index
  end

  def show
  	@g = Group.find_by_zooniverse_id(params[:zoo_id])
  end

end