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

    def dummy_schema
      dummy_db.join 'schema.rb'
    end

    def dummy_migration
      dummy_db.join 'migrate'
    end

    def dummy_database_sqlite
      if Dir.exist? dummy_db
        Dir.chdir(dummy_db){ Dir['*.sqlite3'] }.last
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

    def run_on_database(connection, args, stream=:stdout)
        Dir.chdir(dummy_root) { `#{run_cmd} db:#{connection}:#{args}` }
    end

    def run_on_testable_database(args, stream=:stdout)
      run_on_database(connection, args, stream)
    end

    def run_secondbase(args, stream=:stdout)
      run_on_database second_connection, args, stream
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