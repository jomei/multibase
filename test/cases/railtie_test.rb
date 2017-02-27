require 'test_helper'

class RailtieTest < Multibase::TestCase

  def test_settings_name
    expected_path = 'config/database.yml'
    assert_equal expected_path, railtie_inst.config.multibase.path
    assert_equal expected_path, railtie_klass.config.multibase.path
  end

  def test_settings

  end

  private

  def railtie_inst
    dummy_app.railties.grep(railtie_klass).first
  end

  def railtie_klass
    Multibase::Railtie
  end

end