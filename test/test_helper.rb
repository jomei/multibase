require 'pry'

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
require 'multibase'
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"


require 'bundler/setup'
require 'active_support/test_case'
require 'active_support/testing/autorun'
Bundler.require :default, :development

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end
