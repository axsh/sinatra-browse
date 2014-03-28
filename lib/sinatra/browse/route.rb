# -*- coding: utf-8 -*-

 module Sinatra::Browse
  class Route
    attr_accessor :parameters
    attr_accessor :name
    attr_accessor :match

    # This is here because we're using the name as the keys for the
    # _browse_routes hash. We want to build it outside of this class for that.
    def self.build_name(request_method, path_info)
      "#{request_method}__#{path_info}"
    end

    def initialize(request_method, path_info, parameters = nil)
      @name = build_name(request_method, path_info)
      @match = build_match(request_method, path_info)
      @parameters = parameters || {}
    end

    def matches?(request_method, path_info)
      !! (build_name(request_method,path_info) =~ @match)
    end

    private
    def build_name(request_method, path_info)
      self.class.build_name(request_method, path_info)
    end

    def build_match(request_method, path_info)
      /^#{request_method}__#{path_info.gsub(/:[^\/]*/, '[^\/]*')}$/
    end
  end
end
