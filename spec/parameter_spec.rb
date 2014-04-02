# -*- coding: utf-8 -*-

require "spec_helper"

describe "parameter" do
  let(:body) { JSON.parse(last_response.body) }

  it "throws away parameters that weren't defined" do
    get("features/remove_undefined", a: "a", b: "b", c: "c")
    expect(body.member?('a')).to eq true
    expect(body.member?('b')).to eq true
    expect(body.member?('c')).to eq false
  end

  # This is just a regression test for now
  it "doesn't crash when calling a route that wasn't defined" do
    get("i_dont_exist")
    expect(last_response.errors).to be_empty
  end
end
