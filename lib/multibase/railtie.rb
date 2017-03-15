module Multibase
  class Railtie < Rails::Railtie
    config.multibase = ActiveSupport::OrderedOptions.new
    config.multibase.db_dir = 'db'
    config.multibase.path = 'config/database.yml'
    config.multibase.default_key = 'default'

    initializer 'multibase.handle_database_configuration',
                before: 'active_record.initialize_database' do |app|

      settings = app.config.database_configuration
      # Checks whether default settings exist
      default_settings = settings[config.multibase.default_key]
      fail <<-TEXT.gsub(/ +\|/, '') unless default_settings
        |Default database configuration has not been defined yet.
        |You should either add settings to the `config/database.yml` under the key :#{config.multibase.default_key},
        |or assign another value to `config.data_bases.default_key` in `config/application.rb`.
      TEXT
      config.multibase.settings = settings

      app.config.define_singleton_method(:database_configuration) do
        Rails.application.config.multibase.current_settings
      end

      Multibase.send(:reset).apply_default
    end

    initializer 'multibase.add_watchable_files' do |app|
      connection_keys.each do |connection|
        dir = app.root.join(config.multibase.db_dir, connection)
        config.watchable_files.concat ["#{dir}/schema.rb", "#{dir}/structure.sql"]
      end
    end

    config.after_initialize do |app|
      multibases_dir = app.root.join(config.multibase.db_dir)
      connection_keys.each do |name|
        db_dir = multibases_dir.join name
        FileUtils.mkdir_p(db_dir) unless File.directory?(db_dir)
      end
    end

    def fullpath(extra = nil)
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
      @configuration ||= Rails.application.config.multibase.settings || load_configuration
      @configuration
    end

    def self.load_configuration
      path = Rails.root.join config.multibase.path
      yaml = Pathname.new(path) if path
      if yaml && yaml.exist?
        require 'yaml'
        require 'erb'
        YAML.load(ERB.new(yaml.read).result) || {}
      end
    end

  end
end
