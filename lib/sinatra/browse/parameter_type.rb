# -*- coding: utf-8 -*-

module Sinatra::Browse
  def self.parameter_type(name, &blk)
    const_set "#{name}Type", Class.new(ParameterType, &blk)
  end

  class ParameterType
    attr_reader :name
    attr_reader :default
    attr_reader :validators

    def initialize(name, map)
      @name = name
      @default = map.delete(:default)

      @transform = map.delete(:transform)
      @transform = @transform.to_proc if @transform

      @required = !! map[:required]
      @on_error = map.delete(:on_error)

      @validators = []
      map.each do |key, value|
        if val_blk = @@validator_declarations[key]
          @validators << Validator.new(
            name: key,
            criteria: map[key],
            validation_blk: val_blk
          )
        end
      end

    end

    def default
      @default.is_a?(Proc) ? @default.call : @default
    end

    def required?
      @required
    end

    def validate(params)
      @validators.each do |v|
        return false, build_error_hash(v.name, v.value) unless v.validate(self.name, params)
      end

      true
    end

    def transform(value)
      @transform ? @transform.call(value) : value
    end

    def coerce(value)
      raise NotImplementedError
    end

    def build_error_hash(reason, value)
      {
        reason: reason,
        parameter: self.name,
        value: value,
        on_error: @on_error
      }
    end

    def type
      type_string = self.class.to_s.split("::").last
      type_string[0, type_string.size - 4]
    end

    def to_hash(options = {})
      h = {
        name: @name,
        type: type,
        required: required?,
      }

      if @default
        h[:default] = if @default.is_a?(Proc) && options[:noprocs]
          "dynamically generated"
        else
          @default
        end
      end

      @validators.each { |v| h[v.name.to_sym] = v.criteria }

      h
    end

    #
    # DSL
    #

    def self.coerce(&blk)
      define_method(:coerce) { |value| blk.call(value) }
    end

    def self.validator(name, &blk)
      @@validator_declarations ||= {}

      @@validator_declarations[name] = blk
    end

    #
    # Validators
    #

    # We need a to_s here because the user should be allowed to define dependencies
    # using symbols while the actual keys of the params hash are strings
    validator(:depends_on) { |dep| @params.has_key?(dep.to_s) }
    validator(:in) { |possible_values| possible_values.member?(@value) }
  end
end
