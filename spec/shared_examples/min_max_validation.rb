# -*- coding: utf-8 -*-

shared_examples "a parameter type with min/max validation" do |options|
  test_route = options[:test_route]
  min_key = options[:minimum_value].first.first
  min_val = options[:minimum_value].first.last
  max_key = options[:maximum_value].first.first
  max_val = options[:maximum_value].first.last

  describe "Minimum/Maximum value validation" do
    before(:each) { get("features/#{test_route}", params) }

    describe "min" do
      context "with a parameter that's larger than the given minimum" do
        let(:params) { {min_key => (min_val + 5)} }

        it "works fine and dandy" do
          expect(body["min_test"]).to eq(min_val + 5)
        end
      end

      context "with a parameter that's exactly the given minimum" do
        let(:params) { {min_key => min_val} }

        it "works fine and dandy" do
          expect(body["min_test"]).to eq min_val
        end
      end

      context "with a parameter that's lower than the minimum" do
        let(:params) { {min_key => (min_val - 5)} }

        it "fails with a 400 status" do
          expect(status).to eq 400
        end
      end
    end

    describe "max" do
      context "with a parameter that's lower than the maximum" do
        let(:params) { {max_key => (max_val - 5)} }

        it "works fine and dandy" do
          expect(body["max_test"]).to eq (max_val - 5)
        end
      end

      context "with a parameter that's exactly the given maximum" do
        let(:params) { {max_key => max_val} }

        it "works fine and dandy" do
          expect(body["max_test"]).to eq max_val
        end
      end

      context "with a parameter that's larger than the given maximum" do
        let(:params) { {max_key => (max_val + 5)} }

        it "fails with a 400 status" do
          expect(status).to eq 400
        end
      end
    end
  end
end
