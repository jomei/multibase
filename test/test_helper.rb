require 'pry'

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
require 'multibase'
require File.expand_path('../dummy/config/environment.rb',  __FILE__)
require 'rails/test_help'


require 'bundler/setup'
require 'active_support/test_case'
require 'active_support/testing/autorun'
Bundler.require :default, :development

require_relative 'dummy_app_helpers'

module Multibase
  class TestCase < ActiveSupport::TestCase
    include DummyAppHelpers

    setup    :delete_dummy_files
    teardown :delete_dummy_files

    def establish_connection(connection)
      Multibase.apply connection
    end
  end
end
