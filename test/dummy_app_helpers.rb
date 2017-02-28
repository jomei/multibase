module Multibase
  module DummyAppHelpers

    extend ActiveSupport::Concern

    private

    def database
      'test'
    end

    def connection
      'lite_2'
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

    def dummy_db
      dummy_app.root.join 'db', connection
    end

    def dummy_schema
      dummy_db.join 'schema.rb'
    end

    def dummy_migration
      dummy_db.join 'migrate'
    end

    def dummy_database_sqlite
      Dir.chdir(dummy_db){ Dir['*.sqlite3'] }.first
    end

    def delete_dummy_files
      FileUtils.rm_rf dummy_schema
      Dir.chdir(dummy_db) { FileUtils.rm_rf(dummy_database_sqlite) } if dummy_database_sqlite
      FileUtils.rm_rf(dummy_migration)
    end

    # Runners

    def run_cmd
      'rake'
    end

    def run_on_database(connection, args, stream=:stdout)
      Dir.chdir(dummy_root) { Kernel.system "#{run_cmd} db:#{connection}:#{args}" }
    end

    def run_on_testable_database(args, stream=:stdout)
      run_on_database(connection, args, stream)
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