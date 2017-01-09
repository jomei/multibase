require 'rails'
require 'active_record'
require 'active_record/railtie'

require 'multibase/version'

module Multibase
  def self.config(env)
    config = ActiveRecord::Base.configurations[Railtie.config_key]
    config ? config[env || Rails.env] : nil
  end
end
