module Multibase
  class Railtie < Rails::Railtie
    config.multibase = ActiveSupport::OrderedOptions.new
    config.multibase.db_dir = 'db'
    config.multibase.path = 'config/multibase.yml'
    config.multibase.config_key = 'multibase'
    config.multibase.run_with_db_tasks = true

    config.after_initialize do |app|
      multibases_dir = app.root.join(config.multibase.db_dir)
      connection_names.each do |name|
        db_dir = multibases_dir.join name
        FileUtils.mkdir_p(db_dir) unless File.directory?(db_dir)
      end
    end

    rake_tasks do
      load 'multibase/tasks/database.rake'
    end

    generators do
      require 'rails/multibase/generators/migration_generator'
    end

    initializer 'multibase.add_watchable_files' do |app|
      watchable_files = []
      connection_names.each do |name|
        watchable_files << app.root.join("#{config.multibase.db_path}/#{name}")
      end
      config.watchable_files.concat watchable_files
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
    rescue Psych::SyntaxError => e
      raise "YAML syntax error occurred while parsing #{paths["config/database"].first}. " \
              "Please note that YAML must be consistently indented using spaces. Tabs are not allowed. " \
              "Error: #{e.message}"
    rescue => e
      raise e, "Cannot load `Rails.application.database_configuration`:\n#{e.message}", e.backtrace
    end

    def fullpath(extra=nil)
      path = Rails.root.join(config.multibase.db_dir)
      (extra ? path.join(path, extra) : path).to_s
    end

    def connection_names
      Multibase::Railtie.database_configuration.keys
    end

    def connection?(name)
      connection_names.include? name
    end
  end
end