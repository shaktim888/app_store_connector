#!/bin/env ruby
# -*- encoding: utf-8 -*-
# frozen_string_literal: true

require 'my_app_store_connect/create_request'

module AppStoreConnect
  class UserInvitationCreateRequest < CreateRequest
    data do
      type 'userInvitations'

      attributes do
        property :first_name, required: true
        property :last_name, required: true
        property :email, required: true
        property :roles, required: true
        property :all_apps_visible
        property :provisioning_allowed
      end
    end
  end
end
