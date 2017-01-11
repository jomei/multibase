module Multibase
  class Railtie < Rails::Railtie
    puts 'itittata'
    # binding.pry

    config.multibase = ActiveSupport::OrderedOptions.new
    config.multibase.path = 'db/multibase'
    config.multibase.config_key = 'multibase'
    config.multibase.run_with_db_tasks = true

    config.after_initialize do |app|
      multibase_dir = app.root.join(config.multibase.path)
      FileUtils.mkdir(multibase_dir) unless File.directory?(multibase_dir)
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