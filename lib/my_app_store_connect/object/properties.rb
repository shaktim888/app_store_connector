#!/bin/env ruby
# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'active_support/concern'

module AppStoreConnect
  module Object
    module Properties
      extend ActiveSupport::Concern

      class_methods do
        def properties
          @properties ||= {}
        end

        def property(name, options = {})
          properties[name] = options

          attr_accessor name.to_sym
        end
      end
    end
  end
end
