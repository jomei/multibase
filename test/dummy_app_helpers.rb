module Multibase
  module DummyAppHelpers

    extend ActiveSupport::Concern

    private

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
      dummy_app.root.join 'db'
    end

    def dummy_schema
      dummy_db.join 'schema.rb'
    end

    def dummy_multibase_schema
      dummy_db.join('multibase', 'schema.rb')
    end

    def dummy_database_sqlite
      Dir.chdir(dummy_db){ Dir['*.sqlite3'] }.first
    end

    def dummy_migration
      @dummy_migration ||= begin
        vers = Time.now.utc.strftime '%Y%m%d%H%M%S'
        file = dummy_root.join 'db', 'multibase', 'migrate', "#{vers}_create_foos.rb"
        if rails_50_up?
          migr = %|class CreateFoos < ActiveRecord::Migration[4.2] ; def change ; create_table(:foos) ; end ; end|
        else
          migr = %|class CreateFoos < ActiveRecord::Migration ; def change ; create_table(:foos) ; end ; end|
        end
        File.open(file,'w') { |f| f.write(migr) }
        {version: vers, file: file}
      end
    end

    def delete_dummy_files
      FileUtils.rm_rf dummy_schema
      FileUtils.rm_rf dummy_multibase_schema
      Dir.chdir(dummy_db) { Dir['**/structure.sql'].each { |structure| FileUtils.rm_rf(structure) } }
      Dir.chdir(dummy_db) { FileUtils.rm_rf(dummy_database_sqlite) } if dummy_database_sqlite
      FileUtils.rm_rf(dummy_migration[:file]) if defined?(@dummy_migration) && @dummy_migration
      `mysql -uroot -e "DROP DATABASE IF EXISTS multibase_test"`
    end

    # Runners

    def run_cmd
      'rake'
    end

    def run_db(args, stream=:stdout, with_multibase_tasks=true)
      capture(stream) do
        Dir.chdir(dummy_root) { Kernel.system "env WITH_multibase_TASKS=#{with_multibase_tasks} #{run_cmd} db:#{args}" }
      end
    end

    def run_multibase(args, stream=:stdout)
      capture(stream) do
        Dir.chdir(dummy_root) { Kernel.system "#{run_cmd} db:multibase:#{args}" }
      end
    end

    # Assertions

    def assert_dummy_databases
      assert_equal 'base.sqlite3', dummy_database_sqlite
      assert_match(/multibase_test/, `mysql -uroot -e "SHOW DATABASES"`)
    end

    def refute_dummy_databases
      assert_nil dummy_database_sqlite
      refute_match(/multibase_test/, `mysql -uroot -e "SHOW DATABASES"`)
    end

  end
end