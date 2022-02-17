#!/bin/env ruby
# -*- encoding: utf-8 -*-
# frozen_string_literal: true

module AppStoreConnect
  class CreateRequest
    def self.inherited(klass)
      klass.include(Object::Data)
    end

    def initialize(**kwargs)
      @data = self.class::Data.new(kwargs)
    end
  end
end
