# -*- coding: utf-8 -*-

module Sinatra::Browse
  class ParameterType
    attr_reader :name
    attr_reader :default

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
        return false, build_error_hash(v) unless v.validate(self.name, params)
      end

      true
    end

    def transform(value)
      @transform ? @transform.call(value) : value
    end

    def coerce(value)
      raise NotImplementedError
    end

    def build_error_hash(validator)
      validator = case validator
      when Validator
        validator
      when Symbol
        #TODO: Change validators to hash to make this faster
        @validators.find { |v| v.name == validator }
      end

      {
        reason: validator.name,
        parameter: self.name,
        value: validator.value,
        on_error: @on_error
      }
    end

    def self.validator(name, &blk)
      @@validator_declarations ||= {}

      @@validator_declarations[name] = blk
    end

    #TODO: Investigate why this didn't work without a to_s
    validator(:depends_on) { |dep| @params.has_key?(dep.to_s) }
    validator(:required) { |trueclass| !@value.nil? }
    validator(:in) { |possible_values| possible_values.member?(@value) }
  end
end
