# -*- coding: utf-8 -*-

require "spec_helper"

describe "sinatra-browse" do
  let(:body) { JSON.parse(last_response.body) }
  #before(:each) { get(url, params) }

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

  it "coerses parameters into the defined types" do
    get("features/type_coersion",
      string: "joske",
      integer: "1",
      boolean: "false",
      float: "1.5",
      array: "(1,2,3,4,5,6)",
      hash: "(joske:jos, jefke:jef)"
    )

    expect(body['string']).to be_a(String)
    expect(body['integer']).to be_a(Integer)
    expect(body['boolean']).to be_a(FalseClass)
    expect(body['float']).to be_a(Float)
    expect(body['array']).to be_a(Array)
    expect(body['hash']).to be_a(Hash)
  end
end
