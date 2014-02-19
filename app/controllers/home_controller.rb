
class HomeController < ApplicationController
  def index

  end

  def stats
  	activities_summary = Activity.all.group_by{ |a| a.category }.map{ |c,list| [c,list.size] }.sort_by{|i| -i[1]}
  	@activities_json = activities_summary.map{ |i| "{'label':'#{i[0]}', 'value':#{i[1]}}" }.join(",")
  	max = activities_summary.map{ |i| i[1] }.max
  	floor = Math.log10(max).floor
  	@activities_max = (max/(10.0**floor)).ceil*10**floor
  end
end
