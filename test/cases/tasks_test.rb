require 'test_helper'

class TasksTest < Multibase::TestCase

  def test_db_create
    refute_dummy_databases
    run_on_testable_database :create
    assert_dummy_databases
  end

  def test_db_create_all
    refute_dummy_databases
    run_on_testable_database 'create:all'
    assert_dummy_databases
  end

  def test_db_drop
    run_on_testable_database :create
    run_on_testable_database :drop
    refute_dummy_databases
  end

  def test_db_drop_all
    run_on_testable_database :create
    run_on_testable_database 'drop:all'
    refute_dummy_databases
  end
end
