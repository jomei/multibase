module Multibase
  module DummyAppHelpers

    extend ActiveSupport::Concern

    private

    CONNECTIONS = %w(default lite_2)

    def database
      'test'
    end

    def connection
      CONNECTIONS.first
    end

    def second_connection
      CONNECTIONS.second
    end

    def dummy_app
      ::Dummy::Application
    end

    def dummy_root
      dummy_app.root
    end

    def dummy_config
      dummy_app.config
    end

    def dummy_tmp
      dummy_app.root.join 'tmp'
    end

    def dummy_db(c = connection)
      dummy_app.root.join 'db', c
    end

    def dummy_schema(c = connection)
      dummy_db(c).join 'schema.rb'
    end

    def dummy_migration
      dummy_db.join 'migrate'
    end

    def dummy_database_sqlite
      if Dir.exist? dummy_db
        Dir.chdir(dummy_db){ Dir['*.sqlite3'].sort }.last
      else
        nil
      end
    end

    def delete_dummy_files
      CONNECTIONS.each { |connection| FileUtils.rm_rf dummy_db connection }
    end

    def dummy_schema_cache
      dummy_db.join 'schema_cache.dump'
    end

    # Runners

    def run_cmd
      'rake'
    end

    def run_on_database(connection, args)
        Dir.chdir(dummy_root) { `#{run_cmd} db:#{connection}:#{args}` }
    end

    def run_on_testable_database(args)
      run_on_database(connection, args)
    end

    def run_secondbase(args)
      run_on_database second_connection, args
    end

    def setup_migration
      Dir.chdir(dummy_root) { `rails g multibase:migration CreateFavorites #{connection} post_id:integer count:integer` }
      Dir.chdir(dummy_root) { `rails g multibase:migration CreateComments #{second_connection} post_id:integer count:integer` }

      migration1 = Dir.chdir(dummy_db.join 'migrate'){Dir['*.rb']}.first
      migration2 = Dir.chdir(dummy_db(second_connection).join 'migrate'){Dir['*.rb']}.first

      @timestamp1 = migration1.split('_').first
      @timestamp2 = migration2.split('_').first
    end

    # Assertions

    def assert_dummy_databases
      assert_equal "#{database}.sqlite3", dummy_database_sqlite
    end

    def refute_dummy_databases
      assert_nil dummy_database_sqlite
    end

  end
end
