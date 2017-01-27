require 'rails'
require 'active_record'
require 'active_record/railtie'

require 'multibase/version'
require 'multibase/railtie'
require 'multibase/exec'

module Multibase

  extend ActiveSupport::Autoload

  autoload :Base


  def self.config(connection, env = nil)
    config = Multibase::Railtie.database_configuration[connection]
    config ? config[env || Rails.env] : nil
  end
end
