require 'test_helper'

class ExecTest < Multibase::TestCase
  def test_exec
    Multibase.exec(connection) do
      assert_equal Multibase::Base.connection.class, ActiveRecord::Base.connection.class
      migration_paths = [Multibase::Railtie.fullpath(connection).join('migrate')]
      assert_equal migration_paths, ActiveRecord::Tasks::DatabaseTasks.migrations_paths
      assert_equal Multibase::Railtie.fullpath(connection), ActiveRecord::Tasks::DatabaseTasks.db_dir
    end
  end
end