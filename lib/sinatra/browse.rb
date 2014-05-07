# -*- coding: utf-8 -*-

require 'sinatra/base'

Dir["#{File.dirname(__FILE__)}/browse/*.rb"].each {|f| require f }

module Sinatra::Browse
  def param(name, type, options = {})
    temp_browse_params[name] = options.merge({ type: type })
  end

  def parameter_options(parameter, options)
    #TODO: Raise error when the parameter overridden doesn't exist
    temp_browse_params[parameter].merge! options
  end
  alias :param_options :parameter_options

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
  def set_browse_routes_for(request_method, path_info, description = browse_description, new_params = temp_browse_params)
    new_route = Route.new(request_method, path_info, browse_description, new_params)
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
        #TODO: Optionally throw error for undefined params

        if settings.remove_undefined_parameters
          browse_route.delete_undefined(params, settings.allowed_undefined_parameters)
        end

        browse_route.coerce_type(params)
        browse_route.set_defaults(params)
        validation_result = browse_route.validate(params)
        unless validation_result[:success]
          if validation_result[:on_error].respond_to?(:to_proc)
            error_proc = validation_result.delete(:on_error).to_proc
            instance_exec validation_result, &error_proc
          else
            instance_exec validation_result, &app.default_on_error
          end
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
    return if verb == "HEAD" && !@app.settings.show_head_routes
    @app.set_browse_routes_for(verb, path)
    @app.reset_temp_params
    @app.desc ""
  end
end

module Sinatra; register(Browse) end
