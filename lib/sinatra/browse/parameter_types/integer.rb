# -*- coding: utf-8 -*-

module Sinatra::Browse
  class IntegerType < ParameterType
    def coerce(value)
      Integer(value)
    end
  end
end
