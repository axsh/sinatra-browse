# -*- coding: utf-8 -*-

module Sinatra::Browse
  class ParameterDeclaration
    attr_reader :name
    attr_reader :default
    attr_reader :transform

    def initialize(name, map)
      @name = name
      @default = map[:default]
      @transform = map[:transform]

      @validators = []
      @@validator_declarations.each do |name, blk|
        if map.has_key?(name)
          @validators << Validator.new(
            name: name,
            criteria: map(name),
            validation_blk: blk
          )
        end
      end

    end

    def validate(params)
      @validators.each do |v|
        return false, build_error_hash(v) unless v.validate(self.name, params)
      end

      true
    end

    def coerce(value)
    end

    def build_error_hash(validator)
      {
        reason: validator.name,
        parameter: self.name,
        value: validator.value,
        #TODO: Fill this in further
      }
    end

    def self.validator(name, &blk)
      @@validator_declarations ||= {}

      @@validator_declarations[:name] = blk
    end

    validator(:depends_on) { |dep| @params.has_key?(dep) }
    validator(:required) { |trueclass| !@value.nil? }
    validator(:in) { |possible_values| possible_values.member?(@value) }
  end

  class Validator
    attr_reader :criteria
    attr_reader :value

    def initialize(params)
      @name = params[:name]
      @criteria = params[:criteria]
      @validation_blk = params[:validation_blk]
    end

    def validate(param_name, params)
      @value = params[param_name]
      @params = params

      @validation_blk.call(@criteria)
    end
  end

  class StringDeclaration < ParameterDeclaration
    def coerce(value)
      String(value)
    end

    validator(:format) { |regex| !! @value =~ regex }
    validator(:min_length) { |min_len| @value >= min_len }
    validator(:max_length) { |max_len| @value <= max_len }
  end

  class IntegerDeclaration < ParameterDeclaration
    def coerce(value)
      Integer(value)
    end
  end

  class FloatDeclaration < ParameterDeclaration
    def coerce(value)
      Float(value)
    end
  end

  class BooleanDeclaration < ParameterDeclaration
    def coerce(value)
      #TODO: Raise error if it's something else
      case value
      when "y", "yes", "t", "true", "1"
        true
      when "n", "no", "f", "false", "0"
        false
      end
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

    def has_parameter?(parameter)
      @parameters.has_key?(parameter.to_sym)
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
      @parameters.each { |name, pa| pa.validate(params) }
      #@parameters.each { |k,v|
      #  return fail_validation k, params[k], v, :required if !params[k] && v[:required]
      #  if params[k]
      #    return fail_validation k, params[k], v, :depends_on if v[:depends_on] && !params[v[:depends_on]]
      #    return fail_validation k, params[k], v, :in if v[:in] && !v[:in].member?(params[k])

      #    if v[:type] == :String
      #      return fail_validation k, params[k], v, :format if v[:format] && !(params[k] =~ v[:format])
      #      return fail_validation k, params[k], v, :min_length if v[:min_length] && params[k].length < v[:min_length]
      #      return fail_validation k, params[k], v, :max_length if v[:max_length] && params[k].length > v[:max_length]
      #    end
      #  end
      #}

      true
    end

    def transform(params)
      #TODO: REimplement

      @parameters.each do |name, declaration|
        t = declaration.transform

        params[name] = t.to_proc.call(params[name]) if params[name] && t
      end
    end

    private
    def fail_validation(parameter, value, options, reason)
      return false, {reason: reason , parameter: parameter, value: value}.merge(options)
    end

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

        final_params[name] = Sinatra::Browse.const_get("#{type}Declaration").new(name, map)
      end

      final_params
    end
  end
end
