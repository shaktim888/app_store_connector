#!/bin/env ruby
# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'my_app_store_connect/create_request'

module AppStoreConnect
  class BundleCapabilityCreateRequest < CreateRequest

    data do
      type 'bundleIdCapabilities'

      attributes do
        property :capabilityType, required: true
      end
    end
  end
end
