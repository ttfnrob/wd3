
class HomeController < ApplicationController
  def index

  end

  def stats
  	activities_summary = Activity.all.group_by{ |a| a.category }
  	@activities_json = activities_summary.map{ |c,list| "{'label':'#{c}', 'value':#{list.size}}" }.join(",")
  	max = activities_summary.map{ |c,list| list.size }.max
  	floor = Math.log10(max).floor
  	@activities_max = (max/(10.0**floor)).ceil*10**floor
  end
end
