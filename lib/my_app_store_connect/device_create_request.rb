#!/bin/env ruby
# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'my_app_store_connect/create_request'

module AppStoreConnect
  class DeviceCreateRequest < CreateRequest
    data do
      type 'devices'

      attributes do
        property :name, required: true
        property :platform, required: true
        property :udid, required: true
      end
    end
  end
end
