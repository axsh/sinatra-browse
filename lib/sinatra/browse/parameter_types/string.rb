# -*- coding: utf-8 -*-

module Sinatra::Browse
  module ParameterTypes
    class String < ParameterType
      def coerce(value)
        String(value)
      end

      #TODO: raise error when declaring a validator that doesn't exist
      validator(:format) { |regex| !! (@value =~ regex) }
      validator(:min_length) { |min_len| @value.length >= min_len }
      validator(:max_length) { |max_len| @value.length <= max_len }
    end
  end
end
