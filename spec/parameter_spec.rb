# -*- coding: utf-8 -*-

require "spec_helper"

describe "parameter" do
  it "throws away parameters that weren't defined" do
    get("features/remove_undefined", a: "a", b: "b", c: "c") do |response|
      body = JSON.parse(response.body)
      expect(body.member?('a')).to eq true
      expect(body.member?('b')).to eq true
      expect(body.member?('c')).to eq false
    end
  end
end
