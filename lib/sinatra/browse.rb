# -*- coding: utf-8 -*-

require 'sinatra/base'

Dir["#{File.dirname(__FILE__)}/browse/*.rb"].each {|f| require f }

module Sinatra::Browse
  #
  # Main DSL methods
  #
  def param(name, type, options = {})
    temp_browse_params[name] = options.merge({ type: type })
  end

  def parameter_options(parameter, options)
    if temp_browse_params[parameter].nil?
      msg = "Tried to override undeclared parameter #{parameter}"
      raise Errors::UnknownParameterError, msg
    end

    temp_browse_params[parameter].merge! options
  end
  alias :param_options :parameter_options

  def describe(description)
    @_browse_description = description
  end
  alias :desc :describe

  #
  # Internal stuff
  #
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

  def browse_routes_for(request_method, path_info)
    browse_routes.values.find { |v| v.matches?(request_method, path_info) }
  end

  def create_browse_route(request_method,
                          path_info,
                          description = browse_description,
                          new_params = temp_browse_params)

    new_route = Route.new(request_method,
                          path_info,
                          browse_description,
                          new_params)

    browse_routes[new_route.name] = new_route
  end

  def default_on_error(&blk)
    @default_on_error = blk if block_given?
    @default_on_error
  end

  def self.registered(app)
    @app = app

    app.enable :remove_undefined_parameters
    app.set allowed_undefined_parameters: []

    app.disable :show_head_routes

    app.class_eval {
      def _default_on_error(error_hash)
        halt 400, {
          error: "parameter validation failed",
          parameter: error_hash[:parameter],
          value: error_hash[:value],
          reason: error_hash[:reason]
        }.to_json
      end
    }

    app.default_on_error { |error_hash| _default_on_error(error_hash) }

    app.before do
      browse_route = app.browse_routes_for(request.request_method, request.path_info)

      if browse_route
        if settings.remove_undefined_parameters
          browse_route.delete_undefined(params, settings.allowed_undefined_parameters)
        end

        browse_route.coerce_type(params)
        browse_route.set_defaults(params)

        validation_successful, error_hash = browse_route.validate(params)

        unless validation_successful
          if error_hash[:on_error].respond_to?(:to_proc)
            error_proc = error_hash.delete(:on_error).to_proc
            instance_exec error_hash, &error_proc
          else
            instance_exec error_hash, &app.default_on_error
          end
        end

        browse_route.transform(params)
      end
    end

    app.describe "Displays this (future) browsable API."
    app.param :format, :String, in: ["kusohtml", "json", "yaml"], default: "kusohtml"
    app.get '/browse' do
      Sinatra::Browse.format(params["format"], app.browse_routes).generate
    end
  end

  def self.route_added(verb, path, block)
    return if verb == "HEAD" && !@app.settings.show_head_routes
    @app.create_browse_route(verb, path)
    @app.reset_temp_params
    @app.desc ""
  end
end

module Sinatra; register(Browse) end
