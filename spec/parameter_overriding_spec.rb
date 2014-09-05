# -*- coding: utf-8 -*-

require "spec_helper"

describe "overriding parameter options with param_options" do
  shared_examples_for "standard behaviour" do
    it "uses the parameter exactly like in the helper method" do
      get("features/options_override/#{url}", reused: "garbage")
      expect(status).to eq 400
      get("features/options_override/#{url}", reused: "joske")
      expect(body["reused"]).to eq("joske")
      get("features/options_override/#{url}", reused: "jefke")
      expect(body["reused"]).to eq("jefke")
    end
  end

  context("when not overridden") do
    let(:url) { "not_overridden" }
    include_examples "standard behaviour"
  end

  context "when a default option is added" do
    let(:url) { "default_added" }
    include_examples "standard behaviour"

    it "has set a default value" do
      get("features/options_override/default_added")
      expect(body["reused"]).to eq("joske")
    end
  end

  context "when the 'in' validation is replaced" do
    let(:url) { "in_replaced" }

    it "the 'in' validation is updated" do
      get("features/options_override/#{url}", reused: "joske")
      expect(status).to eq 400
      get("features/options_override/#{url}", reused: "jefke")
      expect(status).to eq 400
      get("features/options_override/#{url}", reused: "jossefien")
      expect(body["reused"]).to eq("jossefien")
      get("features/options_override/#{url}", reused: "nonkel_jan")
      expect(body["reused"]).to eq("nonkel_jan")
    end
  end

  context "when a non existing parameter is overriden" do
    def broken_app
      Class.new(Sinatra::Base) do
        register Sinatra::Browse

        before { content_type :json }

        param :a, :String
        param_options :b, required: true
        get "/features/override_error" do
          params.to_json
        end
      end
    end

    it "raises a UnknownParameterError" do
      error = Sinatra::Browse::Errors::UnknownParameterError
      expect(lambda {broken_app}).to raise_error(error)
    end
  end
end
