# -*- coding: utf-8 -*-

require "date"

module Sinatra::Browse
  module ParameterTypes

    class DateTime < ParameterType
      extend MinMax

      def initialize(name, map)
        # Allow strings for min and max values
        map[:min] = coerce(map[:min]) if map[:min] && !map[:min].is_a?(::DateTime)
        map[:max] = coerce(map[:max]) if map[:max] && !map[:max].is_a?(::DateTime)

        super(name, map)

        # Allow strings to be used for default
        @default = coerce(@default) if @default.is_a?(String)
      end

      def coerce(value)
        # Call parse on ruby's DateTime class rather than the parameter type
        p value
        ::DateTime.parse(value)
      end
    end

  end
end
