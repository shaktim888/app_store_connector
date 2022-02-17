#!/bin/env ruby
# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'active_support/concern'

module AppStoreConnect
  module Object
    module Type
      extend ActiveSupport::Concern

      class_methods do
        def type(type)
          @type = type
        end
      end

      included do
        def type
          self.class.instance_variable_get('@type')
        end
      end
    end
  end
end
