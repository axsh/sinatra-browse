# -*- coding: utf-8 -*-

module Sinatra::Browse
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
      @parameters = parameters || {}
    end

    def to_hash
      {name: @name, description: @description}.merge @parameters
    end

    def matches?(request_method, path_info)
      !! (build_name(request_method,path_info) =~ @match)
    end

    def has_parameter?(parameter)
      @parameters.has_key?(parameter.to_sym)
    end

    def coerce_type(params)
      @parameters.each { |k,v|
        params[k] &&= case v[:type]
        when :Boolean
          cast_to_boolean(params[k])
        else
          send(v[:type], params[k])
        end
      }
    end

    def set_defaults(params)
      @parameters.each { |k,v|
        unless params[k] || v[:default].nil?
          params[k] = v[:default].is_a?(Proc) ? v[:default].call(params[k]) : v[:default]
        end
      }
    end

    def delete_undefined(params, allowed)
      params.delete_if { |i| !(self.has_parameter?(i) || allowed.member?(i)) }
    end

    def validate(params)
      @parameters.each { |k,v|
        return fail_validation k, params[k], v, :required if !params[k] && v[:required]
        if params[k]
          return fail_validation k, params[k], v, :depends_on if v[:depends_on] && !params[v[:depends_on]]
          return fail_validation k, params[k], v, :in if v[:in] && !v[:in].member?(params[k])

          if v[:type] == :String
            return fail_validation k, params[k], v, :format if v[:format] && !(params[k] =~ v[:format])
            return fail_validation k, params[k], v, :min_length if v[:min_length] && params[k].length < v[:min_length]
            return fail_validation k, params[k], v, :max_length if v[:max_length] && params[k].length > v[:max_length]
          end
        end
      }

      true
    end

    def transform(params)
      @parameters.each { |k,v|
        params[k] = v[:transform].to_proc.call(params[k]) if params[k] && v[:transform]
      }
    end

    private
    def cast_to_boolean(param)
      case param
      when "y", "yes", "t", "true", "1"
        true
      when "n", "no", "f", "false", "0"
        false
      end
    end

    def fail_validation(parameter, value, options, reason)
      return false, {reason: reason , parameter: parameter, value: value}.merge(options)
    end

    def build_name(request_method, path_info)
      self.class.build_name(request_method, path_info)
    end

    def build_match(request_method, path_info)
      /^#{request_method}\s\s#{path_info.gsub(/:[^\/]*/, '[^\/]*')}$/
    end
  end
end
