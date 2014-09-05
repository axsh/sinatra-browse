# -*- coding: utf-8 -*-

require "rubygems"
require "rack"
require "rack/test"

require "dummy-app/app"
def app; App end
def body; JSON.parse(last_response.body) end
def status; last_response.status end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.formatter = :documentation
end
