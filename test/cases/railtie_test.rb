require 'test_helper'

class RailtieTest < Multibase::TestCase

  def test_config
    expected_path = 'db/multibase'
    assert_equal expected_path, railtie_inst.config.multibase.path
    assert_equal expected_path, railtie_klass.config.multibase.path
    expected_config_key = 'multibase'
    assert_equal expected_config_key, railtie_inst.config.multibase.config_key
    assert_equal expected_config_key, railtie_klass.config.multibase.config_key
  end

  # def test_fullpath
  #   expected = dummy_db.join('multibase').to_s
  #   assert_equal expected, railtie_inst.fullpath
  #   assert_equal expected, railtie_klass.fullpath
  # end


  private

  def railtie_inst
    dummy_app.railties.grep(railtie_klass).first
  end

  def railtie_klass
    Multibase::Railtie
  end

end