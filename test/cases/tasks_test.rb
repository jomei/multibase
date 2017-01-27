require 'test_helper'

class TasksTest < Multibase::TestCase
  def test_db_create
    # refute_dummy_databases
    run_on_connection :postgre_db, :create
    # assert_dummy_databases
  end
end