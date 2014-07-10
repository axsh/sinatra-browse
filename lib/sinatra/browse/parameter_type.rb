# -*- coding: utf-8 -*-

module Sinatra::Browse
  class ParameterType
    attr_reader :name
    attr_reader :default
    attr_reader :transform

    def initialize(name, map)
      @name = name
      @default = map.delete(:default)
      @transform = map.delete(:transform)
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

    def required?
      @required
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
        on_error: @on_error
      }
    end

    def self.validator(name, &blk)
      @@validator_declarations ||= {}

      @@validator_declarations[name] = blk
    end

    validator(:depends_on) { |dep| @params.has_key?(dep) }
    validator(:required) { |trueclass| !@value.nil? }
    validator(:in) { |possible_values| possible_values.member?(@value) }
  end
end
