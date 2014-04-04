# -*- coding: utf-8 -*-

require "spec_helper"

describe "sinatra-browse" do
  def body; JSON.parse(last_response.body) end
  def status; last_response.status end

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
  end

  describe "transform" do
    it "does a to_proc on whatever was given and calls it on the parameter" do
      get("features/string_validation", transform: "joske")
      expect(body["transform"]).to eq("JOSKE")
    end

    #TODO: Define behaviour for something that doesn't respond to to_proc
  end

  describe "String validation" do
    describe "in" do
      context "with a value present the array provided" do
        it "allows the parameter to go through" do
          get("features/string_validation", in: "joske")
          expect(body['in']).to eq('joske')
          get("features/string_validation", in: "jefke")
          expect(body['in']).to eq('jefke')
        end
      end

      context "with a value not present in the array provided" do
        it "fails with a 400 status" do
          get("features/string_validation", in: "jantje")
          expect(status).to eq 400
          #TODO: Check for error message?
        end
      end
    end

    describe "format" do
      context "with a string matching the format" do
        it "allows the parameter to go through" do
          get("features/string_validation", format: "nw-joske")
          expect(body["format"]).to eq("nw-joske")
        end
      end

      context "with a string that doesn't match the format" do
        it "fails with a 400 status" do
          get("features/string_validation", format: "garbage")
          expect(status).to eq 400
          #TODO: Check for error message?
        end
      end
    end
  end

  describe "Integer validation" do
    describe "in" do
      context "with a range" do
        it "succeeds when given a number within the range" do
          get("features/integer_validation", single_digit: 5)
          expect(body["single_digit"]).to eq(5)
        end

        it "fails when given a number outside of the range" do
          get("features/integer_validation", single_digit: 55)
          expect(status).to eq 400
        end
      end

      context "with an array" do
        it "succeeds when given a number within the array" do
          get("features/integer_validation", first_ten_primes: 7)
          expect(body["first_ten_primes"]).to eq(7)
        end

        it "fails when given a number outside of the array" do
          get("features/integer_validation", first_ten_primes: 55)
          expect(status).to eq 400
        end
      end
    end
  end

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
  end

  describe "depends_on" do
    it "accepts paramter 'a' only when parameter 'b' is also present" do
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

  describe "on_error" do
    it "allows for custom error handling" do
      get("features/error_handing", error: 20)
      expect(status).to eq 200
      expect(last response.body).to eq "we can handle it"
    end
  end

end
