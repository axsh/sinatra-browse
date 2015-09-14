# -*- coding: utf-8 -*-

require "spec_helper"

describe "browsable api" do
  before(:each) { get("browse", format: format) }

  context "in html" do
    let(:format) { "html" }

    it "doesn't crash when calling it" do
      expect(status).to eq 200
    end
  end

  context "in yaml" do
    let(:format) { "yml" }

    it "returns the api documentation in yaml format" do
      b = YAML.load(last_response.body)

      expect(b[3][:route]).to eq "GET  /features/default"

      expect(b[3][:parameters][0]).to eq({
        :name => :a,
        :type => :String,
        :required => false,
        :default => "yay"
      })

      expect(b[3][:parameters][1]).to eq({
        :name => :b,
        :type => :Integer,
        :required => false,
        :default => 11
      })
    end

    it "shows 'dynamically generated' for procs" do
      b = YAML.load(last_response.body)
      expect(b[4][:parameters][0][:default]).to eq "dynamically generated"
    end
  end

  context "in json" do
    let(:format) { "json" }

    it "returns the api documentation in json format" do
      expect(body[3]["route"]).to eq "GET  /features/default"

      expect(body[3]["parameters"][0]).to eq({
        "name" => "a",
        "type" => "String",
        "required" => false,
        "default" => "yay"
      })

      expect(body[3]["parameters"][1]).to eq({
        "name" => "b",
        "type" => "Integer",
        "required" => false,
        "default" => 11
      })
    end

    it "shows 'dynamically generated' for procs" do
      expect(body[4]["parameters"][0]["default"]).to eq "dynamically generated"
    end

    context "when a route has no parameters" do
      it "is still added to the documentation generation" do
        api_spec = YAML.load(get("browse", format: :yaml).body)
        r = api_spec.find { |i| i[:route] == 'GET  /features/route_without_parameters' }

        expect(r).not_to be_nil
      end
    end

  end
end
