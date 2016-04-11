# -*- coding: utf-8 -*-

module Sinatra::Browse
  module ParameterTypes

    class Hash < ParameterType
      def coerce(value)
        if value.respond_to?(:to_hash)
          value.to_hash
        else
          raise ArgumentError, "Unable to coerce '#{value}' to hash. It does not have a to_hash method."
        end
      end
    end

  end
end
