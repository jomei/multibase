require 'test_helper'

class TasksTest < Multibase::TestCase
  def test_db_create
    # refute_dummy_databases
    run_on_connection :postgre_db, :create
    # assert_dummy_databases
  end
  def test_db_drop
    run_db :create
    run_db :drop
    refute_dummy_databases
  end
end