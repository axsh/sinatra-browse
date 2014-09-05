# -*- coding: utf-8 -*-

require "spec_helper"

describe "configuration" do
  describe "disable :remove_undefined_parameters" do
    def app; OtherApp end

    it "doesn't remove undefined parameters" do
      get("features/dont_remove_undefined", a: "joske", b: "jefke")
      expect(body["a"]).to eq("joske")
      expect(body["b"]).to eq("jefke")
    end
  end

  describe "set :allowed_undefined_parameters" do
    def app; SystemParamApp end

    it "sets a couple of parameters that aren't removed when undefined" do
      get("features/dont_remove_allowed", dont_remove: "something_else")
      expect(body["dont_remove"]).to eq "something_else"
    end
  end
end
