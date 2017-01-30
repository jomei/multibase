require 'rails/generators'
require 'rails/generators/active_record'
require 'rails/generators/active_record/migration/migration_generator'
require 'pry'
module Multibase
  class MigrationGenerator < ActiveRecord::Generators::MigrationGenerator
    source_root ActiveRecord::Generators::MigrationGenerator.source_root

    def self.desc
      require 'rails/generators/rails/migration/migration_generator'
      Rails::Generators::MigrationGenerator.desc
    end

    include(Module.new{

      def migration_template(*args)
        connection_name = attributes.first.name
        args[1].sub! 'db/migrate', "db/#{connection_name}/migrate" if args[1]
        super(*args)
      end

    })

  end
end