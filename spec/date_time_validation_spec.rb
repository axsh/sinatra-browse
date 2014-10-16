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

  context "with a string in the 'max' validator" do
    it 'coerces that string into a date and applies the validator' do
      get('features/date_time_validation', string_max: '2005-1-1')
      expect(status).to eq 400
    end
  end
end
