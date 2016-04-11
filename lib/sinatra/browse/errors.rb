# -*- coding: utf-8 -*-

module Sinatra::Browse::Errors
  class SinatraBrowseError < Exception; end

  class UnknownParameterError < SinatraBrowseError; end
  class UnknownParameterTypeError < SinatraBrowseError; end
end
