# -*- coding: utf-8 -*-

require "spec_helper"

describe "path variables" do
  context "when defined using sintra browse" do
    it "sinatra-browse checks work as they do for regular parameters" do
      get("features/working/joske/path/no")
      expect(body["with"]).to eq("JOSKE")
      expect(body["variables"]).to eq(false)
    end
  end

  context "when not defined using sinatra browse" do
    it "they are discarded" do
      get("/features/joske/path/variables")
      expect(body["undefined"]).to be_nil
    end
  end
end
