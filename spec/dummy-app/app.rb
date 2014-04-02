# -*- coding: utf-8 -*-

require "sinatra/base"
require "sinatra/browse"
require "json"

class App < Sinatra::Base
  register Sinatra::Browse

  before { content_type :json }

  param :a, String
  param :b, String
  get "/features/remove_undefined" do
    params.to_json
  end
end
