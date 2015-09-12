# -*- coding: utf-8 -*-

require "spec_helper"

describe "condition" do
  def app; ConditionTestApp end

  it "Doesn't break user defined conditions" do
    get("condition", value: 1)
    expect(body["res"]).to eq("yay")

    get("condition", value: 2)
    expect(body["res"]).to eq("double yay")

    get("condition", value: 3)
    expect(body["res"]).to eq("no yay")

    get("other_condition", value: 'hou oet')
    expect(body["res"]).to eq("de oeten > all")
  end
end
