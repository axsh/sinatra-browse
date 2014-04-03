# -*- coding: utf-8 -*-

require "sinatra/base"
require "sinatra/browse"
require "json"

class App < Sinatra::Base
  register Sinatra::Browse

  before { content_type :json }

  param :a, :String
  param :b, :String
  get "/features/remove_undefined" do
    params.to_json
  end

  param :string, :String
  param :integer, :Integer
  param :boolean, :Boolean
  param :float, :Float
  get "/features/type_coercion" do
    params.to_json
  end

  param :a, :String, default: "yay"
  param :b, :Integer, default: 11
  param :c, :Boolean, default: false
  get "/features/default" do
    params.to_json
  end

  param :in, :String, in: ["joske", "jefke"]
  param :transform, :String, transform: :upcase
  param :format, :String, format: /^nw-[a-z]{1,8}$/ #TODO: Generate examples in docs
  get "/features/string_validation" do
    params.to_json
  end
end
