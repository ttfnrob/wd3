class GroupsController < ApplicationController
  def index
    @diaries = Group.all
  end

  def show
  	@g ||= Group.find_by_zooniverse_id(params[:zoo_id])
    @tags = []
    @g.pages.each do |p|
      type = p.document_type.keys.join(',')
      @tags.push(*p.clusterize(5,0)) if type == 'diary'
    end
  end

end