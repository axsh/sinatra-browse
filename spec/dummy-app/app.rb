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

  param :string, String
  param :integer, Integer
  #param :boolean, Boolean
  param :float, Float
  param :array, Array
  param :hash, Hash
  get "/features/type_coersion" do
    params.to_json
  end
end
