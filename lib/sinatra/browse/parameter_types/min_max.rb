# -*- coding: utf-8 -*-

module Sinatra::Browse
  module ParameterTypes
    # This is a module for parameter types to extend. It will give them the
    # validators defined here.
    module MinMax
      def self.extended(parameter_type)
        parameter_type.validator(:min) { |min| @value >= min }
        parameter_type.validator(:max) { |max| @value <= max }
      end
    end
  end
end
