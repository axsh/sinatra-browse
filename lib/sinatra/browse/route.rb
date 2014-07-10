# -*- coding: utf-8 -*-

module Sinatra::Browse
  class Validator
    attr_reader :criteria
    attr_reader :value
    attr_reader :name

    def initialize(map)
      @name = map[:name]
      @criteria = map[:criteria]
      @validation_blk = map[:validation_blk]
    end

    def validate(param_name, params)
      @value = params[param_name]
      @params = params

      instance_exec @criteria, &@validation_blk
    end
  end

  class Route
    attr_reader :parameters
    attr_reader :name
    attr_reader :match
    attr_reader :description

    class ValidationError < Exception; end

    # This is here because we're using the name as the keys for the
    # _browse_routes hash. We want to build it outside of this class for that.
    def self.build_name(request_method, path_info)
      "#{request_method}  #{path_info}"
    end

    def initialize(request_method, path_info, description, parameters = nil)
      @name = build_name(request_method, path_info)
      @match = build_match(request_method, path_info)
      @description = description
      @parameters = build_parameters(parameters || {})
    end

    def to_hash
      {name: @name, description: @description}.merge @parameters
    end

    def matches?(request_method, path_info)
      !! (build_name(request_method,path_info) =~ @match)
    end

    def has_parameter?(name)
      @parameters.has_key?(name.to_sym)
    end

    def coerce_type(params)
      @parameters.each { |name, pa| params[name] &&= pa.coerce(params[name]) }
    end

    def set_defaults(params)
      @parameters.each { |name, declaration|
        default = declaration.default

        unless params[name] || default.nil?
          params[name] = default.is_a?(Proc) ? default.call(params[name]) : default
        end
      }
    end

    def delete_undefined(params, allowed)
      params.delete_if { |i| !(self.has_parameter?(i) || allowed.member?(i)) }
    end

    def validate(params)
      @parameters.each do |name, pa|
        if params[name] || pa.required?
          success, error_hash = pa.validate(params)
          return false, error_hash unless success
        end
      end

      true
    end

    def transform(params)
      @parameters.each do |name, declaration|
        t = declaration.transform

        params[name] = t.to_proc.call(params[name]) if params[name] && t
      end
    end

    private
    def build_name(request_method, path_info)
      self.class.build_name(request_method, path_info)
    end

    def build_match(request_method, path_info)
      /^#{request_method}\s\s#{path_info.gsub(/:[^\/]*/, '[^\/]*')}$/
    end

    def build_parameters(params_hash)
      final_params = {}

      params_hash.each do |name, map|
        type = map.delete(:type)

        final_params[name] = Sinatra::Browse.const_get("#{type}Type").new(name, map)
      end

      final_params
    end
  end
end
