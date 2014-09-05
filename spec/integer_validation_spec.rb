# -*- coding: utf-8 -*-

require "spec_helper"

describe "Integer validation" do

  describe "min" do
    context "with a parameter that's larger than the given minimum" do
      it "works fine and dandy" do
        get("features/integer_validation", min_test: 15)
        expect(body["min_test"]).to eq 15
      end
    end

    context "with a parameter that's exactly the given minimum" do
      it "works fine and dandy" do
        get("features/integer_validation", min_test: 10)
        expect(body["min_test"]).to eq 10
      end
    end

    context "with a parameter that's lower than the minimum" do
      it "fails with a 400 status" do
        get("features/integer_validation", min_test: 4)
        expect(status).to eq 400
      end
    end
  end

  describe "max" do
    context "with a parameter that's lower than the maximum" do
      it "works fine and dandy" do
        get("features/integer_validation", max_test: 15)
        expect(body["max_test"]).to eq 15
      end
    end

    context "with a parameter that's exactly the given maximum" do
      it "works fine and dandy" do
        get("features/integer_validation", max_test: 20)
        expect(body["max_test"]).to eq 20
      end
    end

    context "with a parameter that's larger than the given maximum" do
      it "fails with a 400 status" do
        get("features/integer_validation", max_test: 24)
        expect(status).to eq 400
      end
    end
  end

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
