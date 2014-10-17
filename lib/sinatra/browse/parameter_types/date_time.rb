# -*- coding: utf-8 -*-

require "date"

module Sinatra::Browse
  module ParameterTypes

    class DateTime < ParameterType
      extend MinMax

      def initialize(name, map)
        # Allow strings for min and max values
        map[:min] = coerce(map[:min]) if map[:min].is_a?(::String)
        map[:max] = coerce(map[:max]) if map[:max].is_a?(::String)

        super(name, map)
      end

      def coerce(value)
        # We add this line because default values also get coerced.
        return value if value.is_a?(::DateTime)

        ::DateTime.parse(value)
      end
    end

  end
end
