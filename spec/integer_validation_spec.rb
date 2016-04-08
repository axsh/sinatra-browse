# -*- coding: utf-8 -*-

require "spec_helper"
require "prime"

describe "Integer validation" do
  it_behaves_like "a parameter type with min/max validation", {
    test_route: 'integer_validation',
    minimum_value: {min_test: 10},
    maximum_value: {max_test: 20}
  }

  it_behaves_like "a parameter type with 'in' validation", {
    test_route: 'features/integer_validation',
    in_key: :single_digit,
    in_value: 1..9,
    fail_value: 500
  }

  it_behaves_like "a parameter type with 'in' validation", {
    test_route: 'features/integer_validation',
    in_key: :first_ten_primes,
    in_value: Prime.take(10),
    fail_value: 4
  }

  context "with a parameter that isn't numeric" do
    it "returns a proper error hash" do
      get("features/integer_validation", single_digit: "I'm not an int")

      expect(last_response.status).to eq(400)

      expect(body["error"]).to eq("parameter validation failed")
      expect(body["parameter"]).to eq("single_digit")
      expect(body["value"]).to eq("I'm not an int")
    end
  end
end
