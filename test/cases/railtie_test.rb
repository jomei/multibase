require 'test_helper'

class RailtieTest < Multibase::TestCase

  def test_config
    expected_path = 'config/multibase.yml'
    assert_equal expected_path, railtie_inst.config.multibase.path
    assert_equal expected_path, railtie_klass.config.multibase.path
  end

  # def test_fullpath
  #   expected = dummy_db.join('multibase').to_s
  #   assert_equal expected, railtie_inst.fullpath
  #   assert_equal expected, railtie_klass.fullpath
  # end

  def test_database_configuration
    # p railtie_klass.database_configuration
  end


  private

  def railtie_inst
    dummy_app.railties.grep(railtie_klass).first
  end

  def railtie_klass
    Multibase::Railtie
  end

end