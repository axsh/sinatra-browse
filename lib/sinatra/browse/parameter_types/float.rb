# -*- coding: utf-8 -*-

module Sinatra::Browse
  parameter_type(:Float) do
    coerce { |value| Float(value) }
  end
end
