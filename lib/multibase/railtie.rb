module Multibase
  class Railtie < Rails::Railtie
    config.multibase = ActiveSupport::OrderedOptions.new
    config.multibase.db_path = 'db'
    config.multibase.config_key = 'multibase'
    config.multibase.run_with_db_tasks = true

    config.after_initialize do |app|
      database_names = Rails.configuration.database_configuration.keys
      multibases_dir = app.root.join(config.multibase.db_path)
      database_names.each do |name|
        db_dir = multibases_dir.join name
        FileUtils.mkdir(db_dir) unless File.directory?(db_dir)
      end
    end

    rake_tasks do
      load 'multibase/tasks/database.rake'
    end

    initializer 'multibase.add_watchable_files' do |app|
      p 'initit1111'
    end

    generators do
      p 'gen'
      require 'rails/multibase/generators/migration_generator'
    end
  end
end