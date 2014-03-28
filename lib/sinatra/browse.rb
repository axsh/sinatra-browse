# -*- coding: utf-8 -*-

require 'sinatra/base'

Dir["#{File.dirname(__FILE__)}/browse/*.rb"].each {|f| require f }

module Sinatra::Browse
  def param(name, type, options = {})
    temp_browse_params[name] = options.merge({ type: type })
  end

  def temp_browse_params
    @_temp_browse_params ||= reset_temp_params
  end

  def reset_temp_params
    @_temp_browse_params = {}
  end

  def browse_routes
    @_browse_routes ||= {}
  end

  def browse_description
    @_browse_description ||= ""
  end

  def describe(description)
    @_browse_description = description
  end
  alias :desc :describe

  def browse_routes_for(request_method, path_info)
    browse_routes.values.find { |v| v.matches?(request_method, path_info) }
  end

  #TODO: Rename method... It doesn't sound like we'd be creating a new route object here
  def set_browse_routes_for(request_method, path_info, description = browse_description , new_params = temp_browse_params)
    new_route = Route.new(request_method, path_info, browse_description, new_params)
    browse_routes[new_route.name] = new_route
  end

  def self.registered(app)
    @app = app

    app.before do
      # Remove all parameters that weren't explicitly defined
      #TODO: Make this optional per route and global
      path = request.path_info
      reqm = request.request_method
      app.browse_routes_for(reqm, path)
      params.delete_if { |i| !app.browse_routes_for(reqm, path).member?(i) }
    end

    # Create the (future) browsable api
    app.get '/browse' do
      output = ""
      app.browse_routes.each { |name, route|
        output += "<h1>#{name}</h1>"
        output += "<p>#{route.description}</p><ul>"
        route.parameters.each { |param_key, param_value|
          output += "<li>#{param_key} #{param_value[:type]}</li>"
        }
        output += "</ul>"
      }
      output
    end
  end

  def self.route_added(verb, path, block)
    @app.set_browse_routes_for(verb, path)
    @app.reset_temp_params
    @app.desc ""
  end
end

module Sinatra; register(Browse) end
