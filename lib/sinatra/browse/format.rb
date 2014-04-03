# -*- coding: utf-8 -*-

module Sinatra::Browse
  def self.format(f, browse_routes)
    case f
    when "kusohtml"
      KusoHtml.new(browse_routes)
    when "markdown"
      Markdown.new(browse_routes)
    end
  end

  class BrowseFormat
    def initialize(browse_routes)
      @browse_routes = browse_routes
    end
  end

  class KusoHtml < BrowseFormat
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

  class Markdown < BrowseFormat
    def generate
      output = ""
      @browse_routes.each { |name, route|
        output += "# #{name}\n\n"
        output += "#{route.description}\n\n"
        route.parameters.each { |param_key, param_value|
          output += "* #{param_key} #{param_value.to_s}\n"
        }
        output += "\n"
      }
      output.gsub("\n", "<br />")
    end
  end
end

