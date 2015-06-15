# -*- coding: utf-8 -*-

require 'sinatra/base'

module Sinatra::Browse
  #
  # Load other files
  #
  require_relative 'browse/format'
  require_relative 'browse/parameter_type'
  require_relative 'browse/route'
  require_relative 'browse/validator'

  module Errors
    require_relative 'browse/errors'
  end

  module ParameterTypes
    module MinMax
      require_relative 'browse/parameter_types/min_max'
    end

    require_relative 'browse/parameter_types/boolean'
    require_relative 'browse/parameter_types/date_time'
    require_relative 'browse/parameter_types/float'
    require_relative 'browse/parameter_types/integer'
    require_relative 'browse/parameter_types/string'
  end

  #
  # Main DSL methods
  #
  def parameter(name, type, options = {})
    temp_browse_params[name] = options.merge({ type: type })
  end
  alias :param :parameter

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

    app.describe "Displays this browsable API."
    app.param :format, :String, in: ["html", "json", "yaml", "yml"], default: "html"
    app.get '/browse' do
      Sinatra::Browse.format(params["format"], app.browse_routes).generate
    end
  end

  def self.route_added(verb, path, block)
    return if verb == "HEAD" && !@app.settings.show_head_routes
    browse_route = @app.create_browse_route(verb, path)
    @app.reset_temp_params
    @app.desc ""

    # Find route and append to conditions.
    signature = @app.routes[verb].find { |sig| sig[0].match(path) } 
    signature[2] << @app.condition do
      if settings.remove_undefined_parameters
        browse_route.delete_undefined(params, settings.allowed_undefined_parameters)
      end

      validation_successful, error_hash = browse_route.process(params)

      unless validation_successful
        if error_hash[:on_error].respond_to?(:to_proc)
          error_proc = error_hash.delete(:on_error).to_proc
          instance_exec error_hash, &error_proc
        else
          instance_exec error_hash, &self.class.default_on_error
        end
      end
    end
    # Reset @conditions
    @app.instance_variable_set(:@conditions, [])
  end
end

module Sinatra; register(Browse) end
