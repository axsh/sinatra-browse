# -*- coding: utf-8 -*-

require "spec_helper"


describe "default values" do
  context "with simple values" do
    it "sets default values for parameters that weren't provided" do
      get("features/default")
      expect(body['a']).to eq('yay')
      expect(body['b']).to eq(11)
      expect(body['c']).to eq(false)
    end
  end

  context "with a proc" do
    it "will call the proc and set the result as the default value" do
      get("features/default_proc")
      expect(body['a']).to eq(2)
    end
  end

  context "with no default provided" do
    it "will not set any value (including nil) for missing parameters" do
      get("features/default")
      expect(body).not_to have_key('default_not_set')
    end
  end

  context "with nil as the default" do
    it "will create a key with nil as it's value" do
      get("features/default")
      expect(body['n']).to be_nil
    end
  end
end

describe "transform" do
  it "does a to_proc on whatever was given and calls it on the parameter" do
    get("features/string_validation", transform: "joske")
    expect(body["transform"]).to eq("JOSKE")
    get("features/string_validation?get_original=1", transform: "joske")
    expect(body["transform"]).to eq("joske")
  end

  #TODO: Define behaviour for something that doesn't respond to to_proc
end

describe "depends_on" do
  it "accepts parameter 'a' only when parameter 'b' is also present" do
    get("features/depends_on", a: "lol")
    expect(status).to eq 400
    get("features/depends_on", a: "lol", b: "lul")
    expect(body["a"]).to eq("lol")
    expect(body["b"]).to eq("lul")
  end

  it "accepts parameter 'b' even when 'a' is not present" do
    get("features/depends_on", b: "lul")
    expect(body["b"]).to eq("lul")
  end
end

describe "required" do
  it "fails when a required parameter wasn't supplied" do
    get("features/required", a: "a cow")
    expect(body["a"]).to eq("a cow")
    get("features/required")
    expect(status).to eq 400
  end
end
