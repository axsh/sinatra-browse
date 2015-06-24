# -*- coding: utf-8 -*-

require "spec_helper"

describe "type coercion" do
  it "coerces parameters into the defined types" do
    get("features/type_coercion",
      string: "joske",
      integer: "1",
      boolean: "false",
      float: "1.5",
    )

    expect(body['string']).to be_a(String)
    expect(body['integer']).to be_a(Integer)
    expect(body['boolean']).to be_a(FalseClass)
    expect(body['float']).to be_a(Float)
  end

  describe "DateTime coercion" do
    accepted_formats = [
      ['RFC 2616', 'Sat, 03 Feb 2001 04:05:06 GMT', '2001-02-03T04:05:06+00:00'],
      ['RFC 2822', 'Sat, 3 Feb 2001 04:05:06 +0700', '2001-02-03T04:05:06+07:00'],
      ['RFC 3339', '2001-02-03T04:05:06+07:00', '2001-02-03T04:05:06+07:00'],
      ['ISO 8601', '2001-02-03T04:05:06+07:00', '2001-02-03T04:05:06+07:00'],
      ['JIS X 0301', 'H13.02.03T04:05:06+07:00', '2001-02-03T04:05:06+07:00'],
      ['year/month/day', '2014/02/05', '2014-02-05T00:00:00+00:00'],
      ['generic text', 'march 2nd', "#{Time.now.year}-03-02T00:00:00+00:00"]
    ]

    accepted_formats.each { |format_name, request_param, expected_response|
      it "coerces a #{format_name} string into a DateTime" do
        get("features/type_coercion", date: request_param)
        expect(body["date"]).to eq expected_response
      end
    }
  end

  describe "Boolean coercion" do
    ["y", "yes", "t", "true", "1"].each do |i|
      it "coerces true for '#{i}'" do
        get("features/type_coercion", boolean: i)
        expect(body['boolean']).to be_a(TrueClass)
      end
    end

    ["n", "no", "f", "false", "0"].each do |i|
      it "coerces false for '#{i}'" do
        get("features/type_coercion", boolean: i)
        expect(body['boolean']).to be_a(FalseClass)
      end
    end
  end
end
