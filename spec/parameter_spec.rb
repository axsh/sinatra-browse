# -*- coding: utf-8 -*-

require "spec_helper"

describe "sinatra-browse" do
  let(:body) { JSON.parse(last_response.body) }

  it "throws away parameters that weren't defined" do
    get("features/remove_undefined", a: "a", b: "b", c: "c")
    expect(body.member?('a')).to eq true
    expect(body.member?('b')).to eq true
    expect(body.member?('c')).to eq false
  end

  # This is just a regression test for now
  #TODO: This seems to happen when defining a route without a slash. Do something about that
  it "doesn't crash when calling a route that wasn't defined" do
    get("i_dont_exist")
    expect(last_response.errors).to be_empty
  end

  it "coerces parameters into the defined types" do
    get("features/type_coercion",
      string: "joske",
      integer: "1",
      boolean: "false",
      float: "1.5",
    )

    expect(body['string']).to be_a(String)
    expect(body['integer']).to be_a(Integer)
    expect(body['boolean']).to be_a(FalseClass)
    expect(body['float']).to be_a(Float)
  end

  describe "Boolean coercion" do
    ["y", "yes", "t", "true", "1"].each do |i|
      it "returns true for '#{i}'" do
        get("features/type_coercion", boolean: i)
        expect(body['boolean']).to be_a(TrueClass)
      end
    end

    ["n", "no", "f", "false", "0"].each do |i|
      it "returns false for '#{i}'" do
        get("features/type_coercion", boolean: i)
        expect(body['boolean']).to be_a(FalseClass)
      end
    end
  end

  describe "default values" do
    it "sets default values for parameters that weren't provided" do
      get("features/default")
      expect(body['a']).to eq('yay')
      expect(body['b']).to eq(11)
      expect(body['c']).to eq(false)
    end
  end

  describe "String validation" do
  end
end
