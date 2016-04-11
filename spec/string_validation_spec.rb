# -*- coding: utf-8 -*-

require "spec_helper"

describe "String validation" do
  it_behaves_like "a parameter type with 'in' validation", {
    test_route: 'features/string_validation',
    in_key: :in,
    in_value: ['joske', 'jefke'],
    fail_value: 'jantje'
  }

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

  describe "min_length" do
    context "with a string longer than the min_length" do
      it "works fine and dandy" do
        get("features/string_validation", min_length: "123456")
        expect(body["min_length"]).to eq("123456")
      end
    end

    context "with a string shorter than the min_length" do
      it "fails with a 400 status" do
        get("features/string_validation", min_length: "1234")
        expect(status).to eq 400
      end
    end

    context "with a string exactly as long as the min_length" do
      it "works fine and dandy" do
        get("features/string_validation", min_length: "12345")
        expect(body["min_length"]).to eq("12345")
      end
    end
  end

  describe "max_length" do
    context "with a string shorter than the max_length" do
      it "works fine and dandy" do
        get("features/string_validation", max_length: "1234")
        expect(body["max_length"]).to eq("1234")
      end
    end

    context "with a string longer than the max_length" do
      it "fails with a 400 status" do
        get("features/string_validation", max_length: "123456")
        expect(status).to eq 400
      end
    end

    context "with a string exactly as long as the max_length" do
      it "works fine and dandy" do
        get("features/string_validation", max_length: "12345")
        expect(body["max_length"]).to eq("12345")
      end
    end
  end
end
