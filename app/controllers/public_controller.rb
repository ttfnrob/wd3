class PublicController < ApplicationController
  
  def index
    @diaries = Group.where :state => 'complete'
  end
  
  def csv
    n = params[:n] || 5
    threshold = params[:threshold].to_i || 2
    g = Group.find_by_zooniverse_id(params[:zoo_id])
    
    @timeline ||= []
    
    Timeline.sort( :page_number, :page_order ).find_each( :group => params[:zoo_id] ) do |t|
      @timeline << t
    end
    
    @timeline = @timeline.select{ |t| t['count'] >= threshold }
    @timeline = @timeline.select{ |t| t['type'].in? params[:filter].split ',' } if params[:filter]
    
    column_names = [
      'Order',
      'Page',
      'Page type',
      'Page number',
      'Count',
      'DateTime',
      'Date',
      'Place',
      'Lat/Lon',
      'Time',
      'Type',
      'Label',
      'Data',
      'Geonames'
    ]
    
    place_cache = {}
    csv = CSV.generate do |csv|
      csv << column_names
      @timeline.each do |t|
        
        unless place_cache.has_key? t['place']
          place_cache[ t['place'] ] = []
          Place.find_each( :label => t['place'] ) do |p|
            place_cache[ t['place'] ] << {:id => p['geoid'], :name => p['name'], :coords => p['coords'] }
          end
        end
        t['geonames'] = place_cache[ t['place'] ]
        csv << [
          t["page_order"],
          t["page"],
          t["page_type"],
          t["page_number"],
          t["count"],
          t['datetime'],
          t['date'],
          t['place'],
          t['coords'].to_s,
          t['time'],
          t["type"],
          t['label'],
          t['votes'],
          t['geonames']
        ]
      end
    end
    
    send_data csv, :filename => "#{params[:zoo_id]}.csv"
  end
  
end