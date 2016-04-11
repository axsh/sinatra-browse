# -*- coding: utf-8 -*-

require "spec_helper"

describe "type coercion" do
  it "coerces parameters into the defined types" do
    get("features/type_coercion",
      string: "joske",
      integer: "1",
      boolean: "false",
      float: "1.5",
      hash: {joske: :jefke}
    )

    expect(body['string']).to be_a(String)
    expect(body['integer']).to be_a(Integer)
    expect(body['boolean']).to be_a(FalseClass)
    expect(body['float']).to be_a(Float)
    expect(body['hash']).to be_a(Hash)
  end

  describe "Hash coercion" do
    it "accepts hash parameters" do
      get("features/type_coercion", "hash[t]=t&hash[f]=f")
      expect(body['hash']).to eq({
        "t" => "t",
        "f" => "f"
      })
    end

    it "returns an error hash and http status 400 for anything else" do
      get("features/type_coercion", hash: "screw!")
      expect(last_response.status).to eq 400
      expect(body).to eq({
        "error" => "parameter validation failed",
        "parameter" => "hash",
        "value" => "screw!",
        "reason" => "Unable to coerce 'screw!' to hash. It does not have a to_hash method."
      })
    end
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
    B = Sinatra::Browse::ParameterTypes::Boolean

    B::TRUE_VALUES.each do |i|
      it "coerces true for '#{i}'" do
        get("features/type_coercion", boolean: i)
        expect(body['boolean']).to be_a(TrueClass)
      end
    end

    B::FALSE_VALUES.each do |i|
      it "coerces false for '#{i}'" do
        get("features/type_coercion", boolean: i)
        expect(body['boolean']).to be_a(FalseClass)
      end
    end

    it "returns an error hash and http status 400 for anything else" do
      get("features/type_coercion", boolean: "far lands or bust")
      expect(status).to eq 400
      expect(body).to eq({
        "error" => "parameter validation failed",
        "parameter" => "boolean",
        "value" => "far lands or bust",
        "reason" => "Not a valid boolean value: 'far lands or bust'. Must be one of the following: #{B::TRUE_VALUES + B::FALSE_VALUES}"
      })
    end
  end
end
