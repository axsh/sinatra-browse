# -*- coding: utf-8 -*-

require 'sinatra/base'

module Sinatra::Browse
  class Route
    attr_accessor :parameters
    attr_accessor :name
    attr_accessor :match

    def self.build_name(request_method, path_info)
      "#{request_method}__#{path_info}"
    end

    def initialize(request_method, path_info, parameters = nil)
      @name = build_name(request_method, path_info)
      @match = build_match(request_method, path_info)
      @parameters = parameters || {}
    end

    def matches?(request_method, path_info)
      !! (build_name(request_method,path_info) =~ @match)
    end

    private
    def build_name(request_method, path_info)
      self.class.build_name(request_method, path_info)
    end

    def build_match(request_method, path_info)
      /^#{request_method}__#{path_info.gsub(/:[^\/]*/, '[^\/]*')}$/
    end
  end

  def param(name, type, options = {})
    temp_params[name] = options.merge({ type: type })
  end

  def temp_params
    @_temp_browse_params ||= reset_temp_params
  end

  def reset_temp_params
    @_temp_browse_params = {}
  end

  def browse_routes
    @_browse_routes ||= {}
  end

  def browse_routes_for(request_method, path_info)
    browse_routes.values.find { |v| v.matches?(request_method, path_info) }
  end

  #TODO: Rename method... It doesn't sound like we'd be creating a new route object here
  def set_browse_routes_for(request_method, path_info, new_params = @_temp_browse_params)
    new_route = Route.new(request_method, path_info, new_params)
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
        route.parameters.each { |param_key, param_value|
          output += "<p>#{param_key} #{param_value[:type]}</p>"
        }
      }
      output
    end
  end

  def self.route_added(verb, path, block)
    @app.temp_params
    @app.set_browse_routes_for(verb, path)
    @app.reset_temp_params
  end
end

module Sinatra; register(Browse) end
