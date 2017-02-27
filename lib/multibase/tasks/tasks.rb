require 'active_record/fixtures'
require 'active_record/schema_dumper'

module Multibase
  # Container for methods called from rake tasks
  module Tasks
    extend self

    BASE             = ActiveRecord::Base
    DB_TASKS         = ActiveRecord::Tasks::DatabaseTasks
    DUMPER           = ActiveRecord::SchemaDumper
    FIXTURES         = ActiveRecord::FixtureSet
    MIGRATOR         = ActiveRecord::Migrator
    SCHEMA           = ActiveRecord::Schema
    SCHEMA_MIGRATION = ActiveRecord::SchemaMigration

    def load_config(key, env = Rails.env)
      Multibase[key].tap do |config|
        config.apply
        DB_TASKS.current_config = config.settings[env]
        DB_TASKS.seed_loader    = config
        DB_TASKS.db_dir         = config.db_dir.to_s
      end
    end

    def fixtures_path(key)
      File.join(DB_TASKS.fixtures_path, key.to_s).tap do |path|
        FileUtils.mkdir_p path
      end
    end

    def migrations_paths(key)
      config        = Multibase[key]
      default_paths = [config.db_migrate.to_s]
      db_root       = config.db_root
      db_dir        = config.db_dir

      custom_paths  = Dir[*DB_TASKS.migrations_paths].map do |path|
        dir = path[db_root] ? path.sub(db_root, db_dir) : File.join(path, key)
        dir.tap { |path| FileUtils.mkdir_p(path) }
      end

      (custom_paths + default_paths).uniq
    end

    delegate :create_current, :create_all, :drop_current, :drop_all,
             :purge_current, :purge_all, :load_seed, to: DB_TASKS

    delegate :current_version, to: MIGRATOR

    def migrate(key)
      DB_TASKS.migrate # TODO: redefine paths!
      dump if BASE.dump_schema_after_migration
    end

    def migrate_to(key, direction, version)
      MIGRATOR.run(direction, migrations_paths(key), version.to_i)
      dump if BASE.dump_schema_after_migration
    end

    def migrate_by(key, direction, step)
      MIGRATOR.send(direction, migrations_paths(key), step.to_i)
      dump if BASE.dump_schema_after_migration
    end

    def pending_migrations(key)
      MIGRATOR.open(migrations_paths(key)).pending_migrations
    end

    def load_fixtures(key, *names)
      dir = Pathname.new(fixtures_path(key)).expand_path

      if names.empty?
        files = Dir.chdir(dir) { Dir['/**/*.yml', '/**/*.yaml'] }
        names = files.map do |file|
          Pathname.new(file).relative_path_from(dir).sub_ext('').to_s
        end
      end

      FIXTURES.create_fixtures dir.to_s, names
    end

    def load_schema(file, env = Rails.env)
      SCHEMA.verbose = false
      DB_TASKS.load_schema BASE.configurations[env], BASE.schema_format, file
    end

    def dump(schema = nil)
      case BASE.schema_format
        when :ruby then dump_schema(schema)
        when :sql  then dump_structure(schema)
      end
    end

    def dump_schema(schema = nil)
      connection = BASE.connection
      filename   = schema || File.join(config.db_dir, 'schema.rb')
      File.open(filename, 'w:utf-8') { |file| DUMPER.dump(connection, file) }
    end

    def dump_structure(schema = nil)
      connection = BASE.connection
      filename   = schema || File.join(config.db_dir, 'structure.sql')
      DB_TASKS.structure_dump(DB_TASKS.current_config, filename)

      if connection.supports_migrations? && SCHEMA_MIGRATION.table_exists?
        File.open(filename, 'a') do |f|
          f.puts BASE.connection.dump_schema_information
          f.print '\n'
        end
      end
    end
  end
end