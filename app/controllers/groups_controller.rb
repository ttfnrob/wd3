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
  
  def map
    @g ||= Group.find_by_zooniverse_id(params[:zoo_id])
    @g.tags 5, 2
    filter = params[:filter] || 'activity'
    timeline = @g.timeline.select{ |t| t['type'].in? filter.split ',' }
    
    features = []
    timeline.reject{|t| t["lon"] == '' }.each do |t|
      features << {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: [ t["long"].to_f, t["lat"].to_f]
        },
        properties: {
          type: t["type"],
          label: t["label"],
          datetime: t["datetime"],
          :'marker-color' => '#00607d',
          :'marker-symbol' => 'circle',
          :'marker-size' => 'medium'
        }
      }
    end
    
    geojson = {
      type: "FeatureCollection",
      features: features
    }
    
    render json: geojson
  end

end