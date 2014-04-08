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
    
    @timeline ||= []
    
    Timeline.find_each( :group => params[:zoo_id] ) do |t|
      @timeline << t
    end
    
    if @timeline.empty?
      g = Group.find_by_zooniverse_id(params[:zoo_id])
      g.tags n.to_i, threshold.to_i
      @timeline = g.timeline
    end
    
    @timeline = @timeline.select{ |t| t['type'].in? params[:filter].split ',' } if params[:filter]
  end
  
  def map
    filter = params[:filter] || 'activity'
    
    timeline ||= []
    
    Timeline.find_each( :group => params[:zoo_id] ) do |t|
      timeline << t
    end
    
    if timeline.empty?
      g = Group.find_by_zooniverse_id(params[:zoo_id])
      g.tags 5, 2
      timeline = g.timeline
    end
    timeline = timeline.select{ |t| t['type'].in? filter.split ',' }
    
    features = []
    timeline.reject{|t| t["coords"].nil? || t['coords'].empty? || t["coords"][0] == 0 }.each do |t|
      features << {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: t['coords']
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
  
  def full_map
    filter = params[:filter] || 'casualties'
    
    timeline ||= []
    
    Timeline.sort(:date).find_each( :type => filter ) do |t|
      timeline << t
    end
    
    if timeline.empty?
      g = Group.find_by_zooniverse_id(params[:zoo_id])
      g.tags 5, 2
      timeline = g.timeline
    end
    # timeline = timeline.select{ |t| t['type'].in? filter.split ',' }
    
    features = []
    timeline.reject{|t| t["coords"].nil? || t['coords'].empty? || t["coords"][0] == 0 }.each do |t|
      features << {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: t['coords']
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