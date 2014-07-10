# -*- coding: utf-8 -*-

module Sinatra::Browse
  class FloatType < ParameterType
    def coerce(value)
      Float(value)
    end
  end
end
