# -*- coding: utf-8 -*-

module MinMaxHelpers
  def it_works_fine_and_dandy
    it "works fine and dandy" do
      expect(status).to eq 200
    end
  end

  def it_fails_with_400_status
    it "fails with a 400 status" do
      expect(status).to eq 400
    end
  end
end

shared_examples "a parameter type with min/max validation" do |options|
  test_route = options[:test_route]
  min_key = options[:minimum_value].first.first
  min_val = options[:minimum_value].first.last
  max_key = options[:maximum_value].first.first
  max_val = options[:maximum_value].first.last

  describe "Minimum/Maximum value validation" do
    extend MinMaxHelpers

    before(:each) { get("features/#{test_route}", params) }

    describe "min" do
      context "with a parameter that's larger than the given minimum" do
        let(:params) { {min_key => (min_val + 5)} }

        it_works_fine_and_dandy
      end

      context "with a parameter that's exactly the given minimum" do
        let(:params) { {min_key => min_val} }

        it_works_fine_and_dandy
      end

      context "with a parameter that's lower than the minimum" do
        let(:params) { {min_key => (min_val - 5)} }

        it_fails_with_400_status
      end
    end

    describe "max" do
      context "with a parameter that's lower than the maximum" do
        let(:params) { {max_key => (max_val - 5)} }

        it_works_fine_and_dandy
      end

      context "with a parameter that's exactly the given maximum" do
        let(:params) { {max_key => max_val} }

        it_works_fine_and_dandy
      end

      context "with a parameter that's larger than the given maximum" do
        let(:params) { {max_key => (max_val + 5)} }

        it_fails_with_400_status
      end
    end
  end
end
