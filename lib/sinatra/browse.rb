# -*- coding: utf-8 -*-

require 'sinatra/base'

module Sinatra::Browse
  def param(name, type, options = {})
    temp_params[name] = options.merge({ type: type })
  end

  def temp_params
    @temp_params ||= reset_temp_params
  end

  def reset_temp_params
    @temp_params = {}
  end

  def route_params
    @route_params ||= {}
  end

  def route_params_for(request_method, path_info)
    route_params.values.find { |v| !("#{request_method}__#{path_info}" =~ v[:match]).nil? }
  end

  def set_route_params_for(request_method, path_info, new_params = @temp_params)
    name = "#{request_method}__#{path_info}"
    route_params[name] = new_params.merge({
      match: /^#{request_method}__#{path_info.gsub(/:[^\/]*/, '[^\/]*')}$/,
      name: name
    })
  end

  def self.registered(app)
    @app = app

    app.before do
      # Remove all parameters that weren't explicitly defined
      #TODO: Make this optional per route and global
      path = request.path_info
      reqm = request.request_method
      app.route_params_for(reqm, path)
      params.delete_if { |i| !app.route_params_for(reqm, path).member?(i) }

      # Create the (future) browsable api
      app.get '/browse' do
        output = ""
        app.route_params.each { |key, value|
          output += "<h1>#{key}</h1>"
          value.each { |param_key, param_value|
            output += "<p>#{param_key} #{param_value[:type]}</p>"
          }
        }
        output
      end
    end
  end

  def self.route_added(verb, path, block)
    @app.temp_params
    @app.set_route_params_for(verb, path)
    @app.reset_temp_params
  end
end

module Sinatra; register(Browse) end
