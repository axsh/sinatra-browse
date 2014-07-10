# -*- coding: utf-8 -*-

module Sinatra::Browse
  class Route
    attr_reader :parameters
    attr_reader :name
    attr_reader :match
    attr_reader :description

    # This is here because we're using the name as the keys for the
    # _browse_routes hash. We want to build it outside of this class for that.
    def self.build_name(request_method, path_info)
      "#{request_method}  #{path_info}"
    end

    def initialize(request_method, path_info, description, declaration_maps = nil)
      @name = build_name(request_method, path_info)
      @match = build_match(request_method, path_info)
      @description = description
      @param_declarations = build_declarations(declaration_maps || {})
    end

    def to_hash
      {name: @name, description: @description}.merge @param_declarations
    end

    def matches?(request_method, path_info)
      !! (build_name(request_method,path_info) =~ @match)
    end

    def has_parameter?(name)
      @param_declarations.has_key?(name.to_sym)
    end

    def process(params)
      @param_declarations.each do |name, pd|
        params[name] = params[name] || pd.default

        # We specifically check for nil here since a boolean's default can be false
        if params[name].nil?
          return false, pd.build_error_hash(:required, nil) if pd.required?
          next
        end

        params[name] = pd.coerce(params[name])

        success, error_hash = pd.validate(params)
        return false, error_hash unless success

        params[name] = pd.transform(params[name])
      end
    end

    def delete_undefined(params, allowed)
      params.delete_if { |i| !(self.has_parameter?(i) || allowed.member?(i)) }
    end

    private
    def build_name(request_method, path_info)
      self.class.build_name(request_method, path_info)
    end

    def build_match(request_method, path_info)
      /^#{request_method}\s\s#{path_info.gsub(/:[^\/]*/, '[^\/]*')}$/
    end

    def build_declarations(declaration_maps)
      final_params = {}

      declaration_maps.each do |name, map|
        type = map.delete(:type)

        final_params[name] = Sinatra::Browse.const_get("#{type}Type").new(name, map)
      end

      final_params
    end
  end
end
