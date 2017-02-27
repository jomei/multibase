require 'pry'

module Multibase
  class Railtie < Rails::Railtie
    config.multibase = ActiveSupport::OrderedOptions.new
    config.multibase.db_dir = 'db'
    config.multibase.path = 'config/database.yml'
    config.multibase.default_key = 'default'

    initializer 'multibase.handle_database_configuration',
                before: 'active_record.initialize_database' do |app|

      binding.pry
      p 'LOLOLAOSDFLASDFASFDAS'

      settings = app.config.database_configuration
      config.multibase.settings = settings

      app.config.define_singleton_method(:database_configuration) do
        Rails.application.config.multibase.current_settings
      end

      Multibase.send(:reset).apply_default
    end

    def init!

    end

    def fullpath(extra=nil)
      path = Rails.root.join(config.multibase.db_dir)
      (extra ? path.join(path, extra) : path)
    end

    def connection_names
      Multibase.keys
    end

    def connection?(name)
      connection_names.include? name
    end

    rake_tasks do
      load 'multibase/tasks/database.rake'
    end

    generators do
      require 'rails/multibase/generators/migration_generator'
    end

    def self.database_configuration
      path = Rails.root.join config.multibase.path
      yaml = Pathname.new(path) if path

      config = if yaml && yaml.exist?
                 require "yaml"
                 require "erb"
                 YAML.load(ERB.new(yaml.read).result) || {}
               elsif ENV["DATABASE_URL"]
                 # Value from ENV['DATABASE_URL'] is set to default database connection
                 # by Active Record.
                 {}
               else
                 raise "Could not load database configuration. No such file - #{paths["config/database"].instance_variable_get(:@paths)}"
               end

      config
    end

  end
end