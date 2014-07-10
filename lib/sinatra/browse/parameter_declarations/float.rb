# -*- coding: utf-8 -*-

module Sinatra::Browse
  class FloatDeclaration < ParameterDeclaration
    def coerce(value)
      Float(value)
    end
  end
end
