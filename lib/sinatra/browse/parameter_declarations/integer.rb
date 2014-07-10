# -*- coding: utf-8 -*-

module Sinatra::Browse
  class IntegerDeclaration < ParameterDeclaration
    def coerce(value)
      Integer(value)
    end
  end
end
