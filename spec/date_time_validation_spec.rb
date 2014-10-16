# -*- coding: utf-8 -*-

require "spec_helper"
require "date"

describe "DateTime validation" do
  it_behaves_like "a parameter type with min/max validation", {
    test_route: 'date_time_validation',
    minimum_value: {min_test: DateTime.ordinal(2001,34,4,5,6,'+7')},
    maximum_value: {max_test: DateTime.ordinal(2005,34,4,5,6,'+7')}
  }
end
