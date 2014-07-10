# -*- coding: utf-8 -*-

module Sinatra::Browse
  class BooleanDeclaration < ParameterDeclaration
    def coerce(value)
      #TODO: Raise error if it's something else
      case value
      when "y", "yes", "t", "true", "1"
        true
      when "n", "no", "f", "false", "0"
        false
      end
    end
  end
end
