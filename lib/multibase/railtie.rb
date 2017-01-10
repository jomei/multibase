module Multibase
  class Railtie < Rails::Railtie
    puts 'itittata'
    binding.pry

    config.multibase = ActiveSupport::OrderedOptions.new
    config.multibase.path = 'db/multibase'
    config.multibase.config_key = 'multibase'
    config.multibase.run_with_db_tasks = true

    config.after_initialize do |app|
      secondbase_dir = app.root.join(config.second_base.path)
      FileUtils.mkdir(secondbase_dir) unless File.directory?(secondbase_dir)
    end

    rake_tasks do
      load 'multibase/tasks/database.rake'
    end

    initializer 'multibase.add_watchable_files' do |app|
      p 'initit1111'
      binding.pry
      secondbase_dir = app.root.join(config.second_base.path)
      # config.watchable_files.concat ["#{secondbase_dir}/schema.rb", "#{secondbase_dir}/structure.sql"]
    end

    generators do
      p 'gen'
      binding.pry
      require 'rails/multibase/generators/migration_generator'
    end
  end
end