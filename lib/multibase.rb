require 'rails'

module Multibase
  require_relative 'multibase/config'
  require_relative 'multibase/railtie'

  class << self
    include  Enumerable
    delegate :each, :[], :keys, to: :@config

    attr_reader :settings

    attr_reader :default_key

    def reset
      Rails.application.config.multibase.tap do |config|
        @default_key = config.default_key
        @settings    = HashWithIndifferentAccess.new(config.settings)
      end

      @config = settings
                    .each_with_object(HashWithIndifferentAccess.new) do |(key, val), hash|
        hash[key] = Config.new(key, val)
      end

      self
    end

    def apply_default
      tap { |db| db[default_key].apply }
    end
  end
end
