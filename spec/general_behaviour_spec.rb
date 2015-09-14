# -*- coding: utf-8 -*-

require "spec_helper"

describe "general behaviour" do
  it "throws away parameters that weren't defined" do
    get("features/remove_undefined", a: "a", b: "b", c: "c")

    expect(body.member?('a')).to eq true
    expect(body.member?('b')).to eq true
    expect(body.member?('c')).to eq false
  end

  it "doesn't crash when calling a route that wasn't defined" do
    get("i_dont_exist")
    expect(last_response.errors).to be_empty
  end

  context "when trying to use validators that don't exist" do
    it "ignores them" do
      get "features/non_existant_validator", a: 12
      expect(status).to eq 200
      expect(body["a"]).to eq 12
    end
  end

  context "when a route has no parameters" do
    it "is still added to the documentation generation" do
      api_spec = YAML.load(get("browse", format: :yaml).body)
      r = api_spec.find { |i| i[:route] == 'GET  /features/route_without_parameters' }

      expect(r).not_to be_nil
    end
  end
end
