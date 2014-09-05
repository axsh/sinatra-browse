# -*- coding: utf-8 -*-

require "spec_helper"

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
