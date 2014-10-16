# -*- coding: utf-8 -*-

shared_examples "a parameter type with 'in' validation" do |options|
  test_route = options[:test_route]
  in_key     = options[:in_key]
  in_val     = options[:in_value]
  fail_value = options[:fail_value]

  describe "in (#{in_val.inspect})" do
    context "with a value present the array provided" do

      in_val.each { |allowed_value|
        it "allows the value (#{allowed_value.inspect}) to go through" do
          get(test_route, in_key => allowed_value)

          result = body[in_key.to_s]
          expect(result).to eq allowed_value
        end
      }

    end

    context "with a value not present in the array (#{fail_value.inspect}) provided" do
      it "fails with a 400 status" do
        get(test_route, in_key => fail_value)
        expect(status).to eq 400
      end
    end

  end
end
