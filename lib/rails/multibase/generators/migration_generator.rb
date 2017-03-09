require 'rails/generators'
require 'rails/generators/active_record'
require 'rails/generators/active_record/migration/migration_generator'

module Multibase
  class MigrationGenerator < ActiveRecord::Generators::MigrationGenerator
    source_root ActiveRecord::Generators::MigrationGenerator.source_root

    def self.desc
      require 'rails/generators/rails/migration/migration_generator'
      Rails::Generators::MigrationGenerator.desc
    end

    def create_migration_file
      @connection_name = attributes.first.name
      if Multibase::Railtie.connection? @connection_name
        attributes.shift
      else
        @connection_name = Multibase.default_key
      end
      super
    end

    include(
        Module.new do
          def migration_template(*args)
            args[1].sub! 'db/migrate', "db/#{@connection_name}/migrate" if args[1]
            super(*args)
          end
        end
    )

  end
end
