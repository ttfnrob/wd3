class GroupsController < ApplicationController
  before_filter :authenticate
  
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
    threshold = params[:threshold].to_i || 2
    g = Group.find_by_zooniverse_id(params[:zoo_id])
    
    Timeline.destroy_all( :group => params[:zoo_id] ) unless g.state == 'complete'
    
    @timeline ||= []
    
    Timeline.sort( :page_number, :page_order ).find_each( :group => params[:zoo_id] ) do |t|
      @timeline << t
    end
    
    if @timeline.empty?
      g.tags n.to_i, threshold
      @timeline = g.timeline
    end
    
    @timeline = @timeline.select{ |t| t['count'] >= threshold }
    @timeline = @timeline.select{ |t| t['type'].in? params[:filter].split ',' } if params[:filter]
  end
  
  def map
    filter = params[:filter] || 'activity'
    g = Group.find_by_zooniverse_id(params[:zoo_id])
    
    Timeline.destroy_all( :group => params[:zoo_id] ) unless g.state == 'complete'
    
    timeline ||= []
    
    Timeline.find_each( :group => params[:zoo_id] ) do |t|
      timeline << t
    end
    
    if timeline.empty?
      g.tags 5, 2
      timeline = g.timeline
    end
    timeline = timeline.select{ |t| t['type'].in? filter.split ',' }
    
    features = []
    timeline.each do |t|
      Place.find_each( :label => t['place'] ) do |p|
        features << {
          type: 'Feature',
          geometry: {
            type: 'Point',
            coordinates: p['coords']
          },
          properties: {
            type: t["type"],
            label: t["label"],
            place: t['place'],
            geonames: p['name'],
            datetime: t["datetime"],
            :'marker-color' => '#00607d',
            :'marker-symbol' => 'circle',
            :'marker-size' => 'medium'
          }
        }
      end
    end
    
    geojson = {
      type: "FeatureCollection",
      features: features
    }
    
    render json: geojson
  end
  
  def full_map
    filter = params[:filter] || 'casualties'
    start_date = Time.parse('01/01/1914')
    end_date = Time.parse('31/12/1919')
    
    features = []
    count = 0
    # timeline = []
#     Timeline.find_each( :type => filter, :datetime.gte => start_date, :datetime.lte => end_date ) do |t|
#       timeline << t
#     end
    
    Place.all().each do |p|
      count += 1
      puts "#{count} #{p['label']}"
      Timeline.find_each( :type => filter, :place => p['label'], :datetime.gte => start_date, :datetime.lte => end_date ) do |t|
        features << {
          type: 'Feature',
          geometry: {
            type: 'Point',
            coordinates: p['coords']
          },
          properties: {
            place: t["place"],
            label: t["label"],
            datetime: t["datetime"],
            diary: t["group"]
          }
        }
      end
    end
  
    
    geojson = {
      type: "FeatureCollection",
      features: features
    }
    
    render json: geojson
  end
  
  def casualty_map
    filter = 'casualties'
    start_date = Time.parse('01/01/1914')
    end_date = Time.parse('31/12/1919')
    
    features = []
    count = 0
    # timeline = []
#     Timeline.find_each( :type => filter, :datetime.gte => start_date, :datetime.lte => end_date ) do |t|
#       timeline << t
#     end
    
    Place.all().each do |p|
      count += 1
      puts "#{count} #{p['label']}"
      Timeline.find_each( :type => filter, :place => p['label'], :datetime.gte => start_date, :datetime.lte => end_date ) do |t|
        properties = {
          place: t["place"],
          label: t["label"],
          datetime: t["datetime"],
          diary: t["group"]
        }
        casualties = t['label'].split ','
        casualties.each do |c|
          pair = c.split ':'
          properties[ pair[0] ] = pair[1].to_i
        end
            
        features << {
          type: 'Feature',
          geometry: {
            type: 'Point',
            coordinates: p['coords']
          },
          properties: properties
        }
      end
    end
  
    
    geojson = {
      type: "FeatureCollection",
      features: features
    }
    
    render json: geojson
  end
  
  def place_map
    
    # if timeline.empty?
#       g = Group.find_by_zooniverse_id(params[:zoo_id])
#       g.tags 5, 2
#       timeline = g.timeline
#     end
    # timeline = timeline.select{ |t| t['type'].in? filter.split ',' }
    
    features = []
    Place.each do |t|
      features << {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: t['coords']
        },
        properties: {
          label: t["label"],
          name: t["name"],
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