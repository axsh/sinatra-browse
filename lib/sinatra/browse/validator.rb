# -*- coding: utf-8 -*-

module Sinatra::Browse
  class Validator
    attr_reader :criteria
    attr_reader :value
    attr_reader :name

    def initialize(map)
      @name = map[:name]
      @criteria = map[:criteria]
      @validation_blk = map[:validation_blk]
    end

    def validate(param_name, params)
      @value = params[param_name]
      @params = params

      instance_exec @criteria, &@validation_blk
    end
  end
end
