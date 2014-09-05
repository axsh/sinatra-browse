# -*- coding: utf-8 -*-

require "spec_helper"

describe "sinatra-browse" do


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

  describe "disable :remove_undefined_parameters" do
    def app; OtherApp end

    it "doesn't remove undefined parameters" do
      get("features/dont_remove_undefined", a: "joske", b: "jefke")
      expect(body["a"]).to eq("joske")
      expect(body["b"]).to eq("jefke")
    end
  end

  describe "set :allowed_undefined_parameters" do
    def app; SystemParamApp end

    it "sets a couple of parameters that aren't removed when undefined" do
      get("features/dont_remove_allowed", dont_remove: "something_else")
      expect(body["dont_remove"]).to eq "something_else"
    end
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







end
