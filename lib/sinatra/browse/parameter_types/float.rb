# -*- coding: utf-8 -*-

module Sinatra::Browse
  module ParameterTypes

    class Float < ParameterType
      extend MinMax

      def coerce(value)
        Float(value)
      end
    end

  end
end
