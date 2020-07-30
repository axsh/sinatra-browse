# -*- coding: utf-8 -*-

module Sinatra::Browse
  class Route
    attr_reader :param_declarations
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
      build_declarations(declaration_maps || {})
    end

    def to_hash(options = {})
      {
        route: @name,
        description: @description,
        parameters: @param_declarations.map { |name, pd| pd.to_hash(options) }
      }
    end

    def matches?(request_method, path_info)
      !! (build_name(request_method,path_info) =~ @match)
    end

    def has_parameter?(name)
      @param_declarations.has_key?(name.to_sym)
    end

    def process(params)
      @param_declarations.each do |name, pd|
        name = name.to_s # The params hash uses strings but declarations use symbols

        params[name] ||= pd.default if pd.default_set?

        # We specifically check for nil here since a boolean's default can be false
        if params[name].nil?
          return false, pd.build_error_hash(:required, nil) if pd.required?
          next
        end

        begin
          params[name] = pd.coerce(params[name])
        rescue
          return false, pd.build_error_hash(:invalid, params[name])
        end

        success, error_hash = pd.validate(params)
        return false, error_hash unless success

        params[name] = pd.transform(params[name])
      end

      true
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
      @param_declarations = {}

      declaration_maps.each do |name, map|
        type = map.delete(:type)
        type_class = Sinatra::Browse::ParameterTypes.const_get(type)

        #TODO: Unit test this error
        unless type_class.is_a?(Class) && type_class.ancestors.member?(ParameterType)
          raise Errors::UnknownParameterTypeError, type_class
        end

        @param_declarations[name] = type_class.new(name, map)
      end
    end
  end
end
