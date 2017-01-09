module Multibase
  class Railtie < Rails::Railtie
    puts 'itittata'
    binding.pry
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