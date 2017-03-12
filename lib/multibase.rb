require 'rails'

module Multibase
  require_relative 'multibase/config'
  require_relative 'multibase/railtie'
  require_relative 'multibase/exec'
  require_relative 'multibase/base'

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

      @config = settings.each_with_object(
          HashWithIndifferentAccess.new
      ) do |(key, val), hash|
        hash[key] = Config.new(key, val)
      end
      self
    end

    def apply_default
      apply default_key
    end

    def apply(key)
      tap { |db| db[key].apply }
    end

  end
end