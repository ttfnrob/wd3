
class ActivitiesController < ApplicationController
  def index
  end

  def summary
  	@distrubtion_all = Activity.all.group_by{ |a| a.category }.map{ |c,list| "{#{c}:#{list.size}" }

  	respond_to do |format|
	    format.html # summary.html.erb
	    format.json  { render :json => @distrubtion_all.to_json() }
    end
  end
end
