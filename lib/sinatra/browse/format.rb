# -*- coding: utf-8 -*-

require 'yaml'
require 'erb'

module Sinatra::Browse
  def self.format(f, browse_routes)
    case f
    when "kusohtml"
      KusoHtml.new(browse_routes)
    when "json"
      JSON.new(browse_routes)
    when "yaml"
      YAML.new(browse_routes)
    when "markdown"
      ErbTemplate.new(browse_routes, "markdown.erb")
    end
  end

  class BrowseFormat
    def initialize(browse_routes)
      @browse_routes = browse_routes
    end
  end

  class ErbTemplate < BrowseFormat
    def initialize(browse_routes, filename)
      super(browse_routes)
      @template = File.read(File.dirname(__FILE__) + "/erb_templates/" + filename)
    end

    def generate
      ERB.new(@template).result(binding)
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

  class JSON < BrowseFormat
    def generate
      @browse_routes.values.map { |br| br.to_hash }.to_json
    end
  end

  class YAML < BrowseFormat
    def generate
      @browse_routes.values.map { |br| br.to_hash }.to_yaml
    end
  end
end

