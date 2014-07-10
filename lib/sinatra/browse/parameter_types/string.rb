# -*- coding: utf-8 -*-

module Sinatra::Browse
  class StringType < ParameterType
    def coerce(value)
      String(value)
    end

    validator(:format) { |regex| !! (@value =~ regex) }
    validator(:min_length) { |min_len| @value.length >= min_len }
    validator(:max_length) { |max_len| @value.length <= max_len }
  end
end
