# -*- coding: utf-8 -*-

module Sinatra::Browse
  module ParameterTypes

    class Boolean < ParameterType
      TRUE_VALUES  = ["y", "yes", "t", "true", "1", true]
      FALSE_VALUES = ["n", "no", "f", "false", "0", false]

      def coerce(value)
        # true and false are included here because they can be set as default
        # values even though only strings will come through http requests
        case value
        when *TRUE_VALUES
          true
        when *FALSE_VALUES
          false
        else
          msg = "Not a valid boolean value: '#{value}'. Must be one of the following:"
          raise ArgumentError, "#{msg} #{TRUE_VALUES + FALSE_VALUES}"
        end
      end
    end

  end
end
