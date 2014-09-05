# -*- coding: utf-8 -*-

require "spec_helper"

describe "error handling" do
  describe "on_error" do
    it "allows for custom per parameter error handling" do
      get("features/error_handing", error: 20)
      expect(status).to eq 200
      expect(last_response.body).to eq "we can handle it"
    end
  end

  describe "self.default_on_error" do
    def app; StandardErrorOverrideApp end

    it "allows the user to define default behaviour on parameter errors" do
      get "/features/default_error_override", a: "b", b: "bbb"
      expect(status).to eq 400
      expect(last_response.body).to eq "we had an error"
    end

    it "allows the user to fall back to standard behaviour by calling _default_on_error" do
      get "/features/default_error_override", a: "a", b: "we need more b"
      expect(status).to eq 400
      expect(body).to eq({
        "error"=>"parameter validation failed",
        "parameter"=>"b",
        "value"=>"we need more b",
        "reason"=>"format"
      })
    end
  end
end
