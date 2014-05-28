require File.expand_path('../boot', __FILE__)

require "csv"

# Pick the frameworks you want:
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "rails/test_unit/railtie"

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module PageProcessor
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    I18n.config.enforce_available_locales = true

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    # config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = false

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    
    config.generators do |g|
      g.orm :mongo_mapper
    end

    config.after_initialize do
        Subject.ensure_index [[:zooniverse_id, 1]], :sparse => true
        Subject.ensure_index [['group.zooniverse_id', 1]], :sparse => true
        Subject.ensure_index [[:state, 1]], :sparse => true
        Group.ensure_index [[:zooniverse_id, 1]], :sparse => true
        Group.ensure_index [[:name, 1]], :sparse => true
        Group.ensure_index [[:state, 1]], :sparse => true
        Classification.ensure_index [[:subject_ids, 1]], :sparse => true
        Discussion.ensure_index [[:title, 1]], :sparse => true
        Tag.ensure_index [[:subject_id, 1]], :sparse => true
        Tag.ensure_index [[:page, 1]], :sparse => true
        Tag.ensure_index [[:group, 1]], :sparse => true
        Tag.ensure_index [[:page_number, 1]], :sparse => true
        Timeline.ensure_index [[:subject_id, 1]], :sparse => true
        Timeline.ensure_index [[:page, 1]], :sparse => true
        Timeline.ensure_index [[:group, 1]], :sparse => true
        Timeline.ensure_index [[:page_number, 1], [:page_order, 1]], :sparse => true
        Timeline.ensure_index [[:page_order, 1]], :sparse => true
        Timeline.ensure_index [[:coords, '2d']], :sparse => true
        Timeline.ensure_index [[:datetime, 1]], :sparse => true
        Timeline.ensure_index [[:type, 1]], :sparse => true
        Timeline.ensure_index [[:place,1]], :sparse => true
        Place.ensure_index [[:coords, '2d']], :sparse => true
        Place.ensure_index [[:label, 1]], :sparse => true
        Place.ensure_index [[:compare, 1]], :sparse => true
    end
  end
end
