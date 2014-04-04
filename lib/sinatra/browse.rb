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

  def parameter_options(parameter, options)
  end
  alias :param_options :parameter_options

  def browse_routes_for(request_method, path_info)
    browse_routes.values.find { |v| v.matches?(request_method, path_info) }
  end

  #TODO: Rename method... It doesn't sound like we'd be creating a new route object here
  def set_browse_routes_for(request_method, path_info, description = browse_description, new_params = temp_browse_params)
    new_route = Route.new(request_method, path_info, browse_description, new_params)
    browse_routes[new_route.name] = new_route
  end

  def self.registered(app)
    @app = app

    app.before do
      browse_route = app.browse_routes_for(request.request_method, request.path_info)

      if browse_route
        browse_route.delete_undefined(params) #TODO: Make this optional per route and global
        browse_route.coerce_type(params)
        browse_route.set_defaults(params)
        begin
          browse_route.validate(params)
        rescue Sinatra::Browse::Route::ValidationError => e
          halt 400, { error: "validation failed", message: e.message }.to_json
        end
        browse_route.transform(params)
      end
    end

    # Create the (future) browsable api
    app.param :format, :String, in: ["kusohtml", "json", "yaml"], default: "kusohtml"
    app.get '/browse' do
      Sinatra::Browse.format(params["format"], app.browse_routes).generate
    end
  end

  def self.route_added(verb, path, block)
    @app.set_browse_routes_for(verb, path)
    @app.reset_temp_params
    @app.desc ""
  end
end

module Sinatra; register(Browse) end
