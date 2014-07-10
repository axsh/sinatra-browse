# -*- coding: utf-8 -*-

module Sinatra::Browse
  class BooleanType < ParameterType
    def coerce(value)
      #TODO: Raise error if it's something else
      # true and false are included here because they can be set as default
      # values even though only strings will come through http requests
      case value
      when "y", "yes", "t", "true", "1", true
        true
      when "n", "no", "f", "false", "0", false
        false
      end
    end
  end
end
