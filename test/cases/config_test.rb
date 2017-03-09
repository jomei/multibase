require 'test_helper'

class ConfigTest < Multibase::TestCase

  private

  def config_instance
    @instance = Multibase::Config.new connection, {}
  end
end
