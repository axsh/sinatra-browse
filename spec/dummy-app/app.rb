# -*- coding: utf-8 -*-

require "sinatra/base"
require "sinatra/browse"
require "json"
require "prime"

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

  param :a, :Integer, default: proc { 1 + 1 }
  get "/features/default_proc" do
    params.to_json
  end

  param :in, :String, in: ["joske", "jefke"]
  param :transform, :String, transform: :upcase
  param :format, :String, format: /^nw-[a-z]{1,8}$/ #TODO: Generate examples in docs
  get "/features/string_validation" do
    params.to_json
  end

  param :single_digit, :Integer, in: 1..9
  param :first_ten_primes, :Integer, in: Prime.take(10)
  get "/features/integer_validation" do
    params.to_json
  end

  def self.helper_method
    param :reused, :String, in: ["joske", "jefke"]
  end

  helper_method
  get "/features/options_override/not_overridden" do
    params.to_json
  end

  helper_method
  param_options :reused, default: "joske"
  get "/features/options_override/default_added" do
    params.to_json
  end

  helper_method
  param_options :reused, in: ["jossefien", "nonkel_jan"]
  get "/features/options_override/in_replaced" do
    params.to_json
  end

  param :a, :String, depends_on: :b
  param :b, :String
  get "/features/depends_on" do
    params.to_json
  end

  param :a, :String, required: true
  get "/features/required" do
    params.to_json
  end
end
