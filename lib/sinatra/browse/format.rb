# -*- coding: utf-8 -*-

require 'yaml'
require 'erb'

module Sinatra::Browse
  def self.format(f, browse_routes)
    case f
    when "html"
      ErbTemplate.new(browse_routes, "html.erb")
    when "json"
      JSON.new(browse_routes)
    when "yaml", "yml"
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
    include ERB::Util

    def initialize(browse_routes, filename)
      super(browse_routes)
      @template = File.read(File.dirname(__FILE__) + "/erb_templates/" + filename)
    end

    def generate
      ERB.new(@template).result(binding)
    end
  end

  class JSON < BrowseFormat
    def generate
      @browse_routes.values.map { |br| br.to_hash(noprocs: true) }.to_json
    end
  end

  class YAML < BrowseFormat
    def generate
      @browse_routes.values.map { |br| br.to_hash(noprocs: true) }.to_yaml
    end
  end
end

