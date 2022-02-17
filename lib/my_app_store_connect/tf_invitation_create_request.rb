#!/bin/env ruby
# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'my_app_store_connect/create_request'

module AppStoreConnect
  class TFInvitationCreateRequest < CreateRequest
    data do
      type 'betaTesters'

      attributes do
        property :firstName, required: true
        property :lastName, required: true
        property :email, required: true
      end
    end
  end
end
