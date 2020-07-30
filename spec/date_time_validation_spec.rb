# -*- coding: utf-8 -*-

require "spec_helper"
require "date"

describe "DateTime validation" do
  it_behaves_like "a parameter type with min/max validation", {
    test_route: 'date_time_validation',
    minimum_value: {min_test: DateTime.ordinal(2001,34,4,5,6,'+7')},
    maximum_value: {max_test: DateTime.ordinal(2005,34,4,5,6,'+7')}
  }

  context "with a string in the 'min' validator" do
    it 'coerces that string into a date and applies the validator' do
      get('features/date_time_validation', string_min: '2014/02/03')
      expect(status).to eq 400
    end
  end

  context "with an invalid date" do
    it "validates the date and returns an error" do
      get("features/date_time_validation", string_min: "2019/02/29")
      expect(status).to eq 400
    end
  end

  [
    [:max, {string_max: '2005-1-1'}],
    [:min, {string_min: '2014-2-4'}]
  ].each { |validator, fail_params|
    context "with a string in the '#{validator}' validator" do
      it 'coerces that string into a date and applies the validator' do
        get('features/date_time_validation', fail_params)
        expect(status).to eq 400
      end
    end
  }

  [
    [:String, '2014-02-05T00:00:00+00:00'],
    [:DateTime, DateTime.new(2012, 12, 05).to_s],
    [:proc,  DateTime.new(2000, 01, 01).to_s]
  ].each { |type, expected_response|
    context "with a #{type} set as default" do
      it 'coerces the default value into a date' do
        get('features/date_time_validation')
        expect(body["default_#{type.downcase}"]).to eq expected_response
      end
    end
  }
end
