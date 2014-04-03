# -*- coding: utf-8 -*-

module Sinatra::Browse
  def self.format(f, browse_routes)
    KusoHtml.new(browse_routes) if f == "kusohtml"
  end

  class KusoHtml
    def initialize(browse_routes)
      @browse_routes = browse_routes
    end

    def generate
      output = ""
      @browse_routes.each { |name, route|
        output += "<h3>#{name}</h3>"
        output += "<p>#{route.description}</p><ul>"
        route.parameters.each { |param_key, param_value|
          output += "<li>#{param_key} #{param_value.to_s}</li>"
        }
        output += "</ul>"
      }
      output
    end
  end
end

