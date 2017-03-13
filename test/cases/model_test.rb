require 'test_helper'

class ModelTest < Multibase::TestCase
  setup do
    setup_migration

    run_on_testable_database :create
    run_on_testable_database :migrate

    run_secondbase :create
    run_secondbase :migrate
  end

  def test_create_model
    Favorite.new(count: 1).save!
    assert Favorite.count == 1
  end
end
