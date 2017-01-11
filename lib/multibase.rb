require 'rails'
require 'active_record'
require 'active_record/railtie'

require 'multibase/version'
require 'multibase/railtie'

module Multibase

  extend ActiveSupport::Autoload

  autoload :Base

  def self.config(env)
    config = ActiveRecord::Base.configurations[Railtie.config_key]
    config ? config[env || Rails.env] : nil
  end
end
