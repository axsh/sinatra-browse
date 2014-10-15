# -*- coding: utf-8 -*-

module Sinatra::Browse
  module Errors
    class UnknownParameterError < Exception; end
    class UnknownParameterTypeError < Exception; end
  end
end
