#!/bin/env ruby
# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'my_app_store_connect/create_request'

module AppStoreConnect
  class BetaTesterInvitationsRequest < CreateRequest
    data do
      type 'betaTesterInvitations'

      attributes do
        
      end
    end
  end
end
