# -*- coding: utf-8 -*-

module Sinatra::Browse
  module ParameterTypes

    class Integer < ParameterType
      extend MinMax

      def coerce(value)
        Integer(value)
      end
    end

  end
end
