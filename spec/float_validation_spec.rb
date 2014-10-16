# -*- coding: utf-8 -*-

require "spec_helper"

describe "Float validation" do
  it_behaves_like "a parameter type with min/max validation", {
    test_route: 'float_validation',
    minimum_value: {min_test: 10.3},
    maximum_value: {max_test: 5.6}
  }
end

