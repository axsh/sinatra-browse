# -*- coding: utf-8 -*-

require "sinatra/base"
require "sinatra/browse"
require "json"
require "prime"

# This application is just here so we can test disabling the remove_undefined_parameters flag
class OtherApp < Sinatra::Base
  register Sinatra::Browse

  before { content_type :json }

  disable :remove_undefined_parameters

  param :a, :String
  get "/features/dont_remove_undefined" do
    params.to_json
  end
end

class SystemParamApp < Sinatra::Base
  register Sinatra::Browse

  before { content_type :json }

  set allowed_undefined_parameters: ["dont_remove"]

  param :a, :String
  get "/features/dont_remove_allowed" do
    params.to_json
  end
end

class StandardErrorOverrideApp < Sinatra::Base
  register Sinatra::Browse

  default_on_error do |error_hash|
    case error_hash[:reason]
    when :in
      halt 400, "we had an error"
    else
      _default_on_error(error_hash)
    end
  end

  param :a, :String, in: ["a"]
  param :b, :String, format: /^bbb$/
  get "/features/default_error_override" do
    params.to_json
  end
end

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
  param :min_length, :String, min_length: 5
  param :max_length, :String, max_length: 5
  param :get_original, :String
  get "/features/string_validation" do
    if params[:get_original]
      orig_params.to_json
    else
      params.to_json
    end
  end

  param :single_digit, :Integer, in: 1..9
  param :first_ten_primes, :Integer, in: Prime.take(10)
  param :min_test, :Integer, min: 10
  param :max_test, :Integer, max: 20
  get "/features/integer_validation" do
    params.to_json
  end

  def self.helper_method
    param :get_original, :String
    param :reused, :String, in: ["joske", "jefke"]
  end

  helper_method
  get "/features/options_override/not_overridden" do
    if params["get_original"]
      orig_params.to_json
    else
      params.to_json
    end
  end

  helper_method
  param_options :reused, default: "joske"
  get "/features/options_override/default_added" do
    if params["get_original"]
      orig_params.to_json
    else
      params.to_json
    end
  end

  helper_method
  param_options :reused, in: ["jossefien", "nonkel_jan"]
  get "/features/options_override/in_replaced" do
    if params["get_original"]
      orig_params.to_json
    else
      params.to_json
    end
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

  param :error, :Integer, in: 1..9, on_error: proc { halt 200, "we can handle it" }
  get "/features/error_handing" do
    params.to_json
  end
end
