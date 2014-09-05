# -*- coding: utf-8 -*-

module Sinatra::Browse
  parameter_type(:Integer) do
    coerce { |value| Integer(value) }

    validator(:min) { |min| @value >= min }
    validator(:max) { |max| @value <= max }
  end
end
