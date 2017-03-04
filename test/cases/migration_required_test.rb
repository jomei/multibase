require 'test_helper'

class MigrationRequiredTest < Multibase::TestCase

  setup do
    setup_migration
  end

  def test_db_test_load_structure
    run_on_testable_database :create
    assert_dummy_databases
    run_on_testable_database 'test:purge'
    Dir.chdir(dummy_root) { `env SCHEMA_FORMAT=sql rake db:migrate` }
    Dir.chdir(dummy_root) { `rake db:test:load_structure` }
    establish_connection connection
    assert_connection_tables ActiveRecord::Base, %w(users posts)
    assert_connection_tables Multibase::Base, ['comments']
  end

  def test_database_version
    run_on_testable_database :create
    assert_match(/version: 0/, run_secondbase(:version))
    run_on_testable_database :migrate
    assert_match(/version: @timestamp1/, run_on_testable_database(:version))
  end

  def test_db_test_load_schema
    skip
    run_on_testable_database :create
    assert_dummy_databases
    run_on_testable_database 'test:purge'
    run_on_testable_database :migrate
    Dir.chdir(dummy_root) { `rake db:#{database}:load_schema` }
    establish_connection connection
    assert_connection_tables ActiveRecord::Base, %w(users posts)
    assert_connection_tables Multibase::Base, ['comments']
  end

  def test_db_test_schema_cache_dump
    skip
    run_on_testable_database :create
    run_on_testable_database :migrate
    assert_dummy_databases
    Dir.chdir(dummy_root) { `rake db:schema:cache:dump` }
    assert File.file?(dummy_schema_cache), 'dummy schema cache does not exist'
    assert File.file?(dummy_schema_cache), 'dummy database schema cache does not exist'
    cache1 = Marshal.load(File.binread(dummy_schema_cache))
    cache2 = Marshal.load(File.binread(dummy_schema_cache))
    source_method = :data_sources
    assert cache1.send(source_method, 'posts'),    'base should have posts table in cache'
    refute cache1.send(source_method, 'comments'), 'base should not have comments table in cache'
    refute cache2.send(source_method, 'posts'),    'database should not have posts table in cache'
    assert cache2.send(source_method, 'comments'), 'database should have comments table in cache'
  end

  def test_abort_if_pending
    run_on_testable_database :create
    run_on_testable_database :migrate
    assert run_on_testable_database(:abort_if_pending_migrations, :stderr)

    version = dummy_migration[:version]
    stdout = run_on_testable_database :abort_if_pending_migrations
    assert_match(/1 pending migration/, stdout)
    assert_match(/#{version}/, stdout)
  end

  def test_db_purge_all
    run_on_testable_database :create
    run_on_testable_database :migrate
    assert_dummy_databases
    run_on_testable_database 'purge:all'
    establish_connection connection
    assert_no_tables
  end

  def test_db_purge
    run_on_testable_database :create
    run_on_testable_database :migrate
    assert_dummy_databases
    run_on_testable_database :purge
    establish_connection connection
    assert_no_tables
  end

  def test_db_migrate
    skip
    run_on_testable_database :create
    run_on_testable_database :migrate
    # First database and schema.
    schema = File.read(dummy_schema)
    assert_match %r{version: @timestamp1}, schema
    assert_match %r{create_table "users"}, schema
    assert_match %r{create_table "posts"}, schema
    refute_match %r{create_table "comments"}, schema
    assert_connection_tables ActiveRecord::Base, %w(users posts)
    # Second database and schema.
    establish_connection(second_connection)
    schema = File.read(dummy_schema)
    assert_match %r{version: @timestamp2}, schema
    refute_match %r{create_table "users"}, schema
    refute_match %r{create_table "posts"}, schema
    assert_match %r{create_table "comments"}, schema
    assert_connection_tables Multibase::Base, ['comments']
  end

  def migrate_updown
    run_on_testable_database :create
    run_on_testable_database :migrate
    assert_match(/no migration.*@timestamp1/i, run_on_testable_database('migrate:down VERSION=@timestamp1', :stderr))
    run_on_testable_database 'migrate:down VERSION=@timestamp1'
    schema = File.read(dummy_schema)
    refute_match %r{version: @timestamp1}, schema
    refute_match %r{create_table "comments"}, schema
    assert_match(/no migration.*@timestamp1/i, run_on_testable_database('migrate:up VERSION=@timestamp1', :stderr))
    run_on_testable_database 'migrate:up VERSION=@timestamp1'
    schema = File.read(dummy_schema)
    assert_match %r{version: @timestamp1}, schema
    assert_match %r{create_table "comments"}, schema
  end

  def migrate_reset

    run_on_testable_database :create
    run_on_testable_database :migrate
    schema = File.read(dummy_schema)

    assert_match %r{version: @timestamp1}, schema
    assert_match %r{create_table "comments"}, schema
    FileUtils.rm_rf dummy_schema
    run_secondbase 'migrate:reset'
    schema = File.read(dummy_schema)
    assert_match %r{version: @timestamp1}, schema
    assert_match %r{create_table "comments"}, schema
  end

  def migrate_redo

    run_on_testable_database :create
    run_on_testable_database :migrate
    schema = File.read(dummy_schema)
    assert_match %r{version: @timestamp1}, schema
    assert_match %r{create_table "comments"}, schema
    FileUtils.rm_rf dummy_schema
    run_secondbase 'migrate:redo'
    schema = File.read(dummy_schema)
    assert_match %r{version: @timestamp1}, schema
    assert_match %r{create_table "comments"}, schema
    # Can redo latest Multibase migration using previous VERSION env.
    version = dummy_migration[:version]
    run_on_testable_database :migrate
    assert_match %r{version: #{version}}, File.read(dummy_schema)
    establish_connection connection
    Comment.create! body: 'test', user_id: 420
    run_secondbase 'migrate:redo VERSION=@timestamp1'
    schema = File.read(dummy_schema)
    assert_match %r{version: #{version}}, schema
    assert_match %r{create_table "comments"}, schema
    establish_connection second_connection
    assert_nil Comment.first
  end

  def migrate_status

    run_on_testable_database :create
    stream = :stdout
    assert_match %r{migrations table does not exist}, run_secondbase('migrate:status', stream)
    run_on_testable_database :migrate
    assert_match %r{up.*@timestamp1}, run_secondbase('migrate:status')
    version = dummy_migration[:version]
    status = run_secondbase('migrate:status')
    assert_match %r{up.*@timestamp1}, status
    assert_match %r{down.*#{version}}, status
  end

  def forward_and_rollback
    run_on_testable_database :create
    run_on_testable_database :migrate
    schema = File.read(dummy_schema)
    assert_match %r{version: @timestamp1}, schema
    refute_match %r{create_table "foos"}, schema
    version = dummy_migration[:version] # ActiveRecord does not support start index 0.
    run_secondbase :forward
    schema = File.read(dummy_schema)
    assert_match %r{version: #{version}}, schema
    assert_match %r{create_table "foos"}, schema
    run_secondbase :rollback
    schema = File.read(dummy_schema)
    assert_match %r{version: @timestamp1}, schema
    refute_match %r{create_table "foos"}, schema
  end

  def test_db_test_purge
    run_on_testable_database :create
    assert_dummy_databases
    run_on_testable_database 'test:purge'
    establish_connection connection
    assert_no_tables
  end

  def test_db_setup
    run_on_testable_database :create
    run_on_testable_database :migrate
    assert_dummy_databases
    run_on_testable_database :drop
    refute_dummy_databases
    run_on_testable_database :setup
    assert_dummy_databases
  end


  private

  def setup_migration
    Dir.chdir(dummy_root) { `rails g multibase:migration CreateFavorites #{connection} post_id:integer count:integer` }
    Dir.chdir(dummy_root) { `rails g multibase:migration CreateComments #{second_connection} post_id:integer count:integer` }

    migration1 = Dir.chdir(dummy_db.join 'migrate'){Dir['*.rb']}.first
    migration2 = Dir.chdir(dummy_db(second_connection).join 'migrate'){Dir['*.rb']}.first

    @timestamp1 = migration1.split('_').first
    @timestamp2 = migration2.split('_').first
  end


  def assert_no_tables
    if ActiveRecord::Base.connection.respond_to? :data_sources
      assert_equal [], ActiveRecord::Base.connection.data_sources
      assert_equal [], Multibase::Base.connection.data_sources
    else
      assert_equal [], ActiveRecord::Base.connection.tables
      assert_equal [], Multibase::Base.connection.tables
    end
  end

  def assert_connection_tables(model, expected_tables)
    establish_connection connection

    if ActiveRecord::Base.connection.respond_to? :data_sources
      tables = model.connection.data_sources
    else
      tables = model.connection.tables
    end

    expected_tables.each do |table|
      message = "Expected #{model.name} tables #{tables.inspect} to include #{table.inspect}"
      assert tables.include?(table), message
    end
  end

end