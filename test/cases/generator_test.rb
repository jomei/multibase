require 'test_helper'

class GeneratorTest < Multibase::TestCase
  teardown do
    delete_generated_migration
    delete_generated_migration_base
  end

  def test_migration
    output = Dir.chdir(dummy_root) { `rails g postgre_db:migration CreateFavorites post_id:integer count:integer` }
    assert_match %r{create.*db/secondbase/migrate/.*create_favorites\.rb}, output
    migration = generated_migration_data
    assert_match %r{create_table :favorites}, migration
    assert_match %r{t.integer :post_id}, migration
    assert_match %r{t.integer :count}, migration
  end
  private

  def generated_migration
    Dir["#{dummy_db}/postgre_db/migrate/*favorites.{rb}"].first
  end

  def delete_generated_migration
    FileUtils.rm_rf(generated_migration) if generated_migration
  end

  def delete_generated_migration_base
    FileUtils.rm_rf(generated_migration_base) if generated_migration_base
  end

  def generated_migration_base
    Dir["#{dummy_db}/migrate/*add_base*.{rb}"].first
  end

end