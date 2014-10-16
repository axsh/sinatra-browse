# -*- coding: utf-8 -*-

require "rubygems"
require "rack"
require "rack/test"

require "dummy-app/app"
def app; App end
def body; JSON.parse(last_response.body) end
def status; last_response.status end

require_relative 'shared_examples/min_max_validation'
require_relative 'shared_examples/in_validation'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.formatter = :documentation
end

module ExampleHelpers
  def it_works_fine_and_dandy
    it "works fine and dandy" do
      expect(status).to eq 200
    end
  end

  def it_fails_with_400_status
    it "fails with a 400 status" do
      expect(status).to eq 400
    end
  end
end
