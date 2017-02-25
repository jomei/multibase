module Multibase
  class Config
    attr_reader :key

    attr_reader :settings

    def initialize(key, settings)
      @key      = key.to_s
      @settings = HashWithIndifferentAccess.new(settings)
    end

    def db_root
      @db_root ||= Rails.root.join('db').tap { |dir| FileUtils.mkdir_p dir }
    end

    def db_dir
      @db_dir ||= db_root.join(key).tap { |dir| FileUtils.mkdir_p(dir) }
    end

    def db_migrate
      @db_migrate ||= db_dir.join('migrate').tap { |dir| FileUtils.mkdir_p dir }
    end

    def db_seed
      @db_seed ||= db_dir.join('seed.rb')
    end

    def load_seed
      load(db_seed) if db_seed.exist?
      self
    end

    def current_settings
      settings[Rails.env]
    end

    def apply(new_settings = settings)
      Rails.application.config.multibase.current_settings = new_settings
      ActiveRecord::Base.configurations = new_settings
      ActiveRecord::Base.establish_connection
    end
  end
end