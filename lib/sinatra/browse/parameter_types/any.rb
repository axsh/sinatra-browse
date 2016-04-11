# -*- coding: utf-8 -*-

module Sinatra::Browse
  module ParameterTypes

    class Any < ParameterType
      def coerce(value)
        value
      end
    end

  end
end
