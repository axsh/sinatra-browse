# -*- coding: utf-8 -*-

require "rubygems"
require "rack"
require "rack/test"

require "dummy-app/app"
def app; App end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.formatter = :documentation
  config.color_enabled = true
end
