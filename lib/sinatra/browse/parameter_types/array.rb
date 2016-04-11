# -*- coding: utf-8 -*-

module Sinatra::Browse
  module ParameterTypes

    class Array < ParameterType
      def coerce(value)
        if value.respond_to?(:to_a)
          value.to_a
        else
          raise ArgumentError, "Unable to coerce '#{value}' to array. It does not have a to_a method."
        end
      end
    end

  end
end
