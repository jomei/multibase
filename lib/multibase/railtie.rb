module Multibase
  class Railtie < Rails::Railtie
    config.multibase = ActiveSupport::OrderedOptions.new
    config.multibase.db_dir = 'db'
    config.multibase.path = 'config/database.yml'
    config.multibase.default_key = 'default'

    initializer 'multibase.handle_database_configuration',
                before: 'active_record.initialize_database' do |app|

      settings = app.config.database_configuration
      config.multibase.settings = settings

      app.config.define_singleton_method(:database_configuration) do
        Rails.application.config.multibase.current_settings
      end

      Multibase.send(:reset).apply_default
    end

    config.after_initialize do |app|
      multibases_dir = app.root.join(config.multibase.db_dir)
      connection_keys.each do |name|
        db_dir = multibases_dir.join name
        FileUtils.mkdir_p(db_dir) unless File.directory?(db_dir)
      end
    end

    def fullpath(extra=nil)
      path = Rails.root.join(config.multibase.db_dir)
      (extra ? path.join(path, extra) : path)
    end

    def connection_keys
      self.class.database_configuration.keys
    end

    def connection?(name)
      connection_keys.include? name
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
      @configuration ||= if yaml && yaml.exist?
        require 'yaml'
        require 'erb'
        YAML.load(ERB.new(yaml.read).result) || {}
      elsif ENV['DATABASE_URL']
        # Value from ENV['DATABASE_URL'] is set to default database connection
        # by Active Record.
        {}
      else
        raise "Could not load database configuration. No such file - #{paths["config/database"].instance_variable_get(:@paths)}"
      end
      @configuration
    end

  end
end
