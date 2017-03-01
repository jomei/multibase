require 'test_helper'

class RailtieTest < Multibase::TestCase

  def test_settings_path
    expected_path = 'config/database.yml'
    assert_equal expected_path, railtie_inst.config.multibase.path
    assert_equal expected_path, railtie_klass.config.multibase.path
  end

  def test_connection_keys
    assert_equal railtie_klass.connection_keys, %w(default lite_2)
  end

  def test_connection?
    assert railtie_klass.connection? connection
  end

  def test_fullpath
    path = Rails.root.join 'db/migrate'
    assert_equal railtie_klass.fullpath('migrate'), path
  end

  private

  def railtie_inst
    dummy_app.railties.grep(railtie_klass).first
  end

  def railtie_klass
    Multibase::Railtie
  end

end