# -*- coding: utf-8 -*-

module Sinatra::Browse
  parameter_type(:Integer) do
    coerce { |value| Integer(value) }
  end
end
