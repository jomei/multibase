module Multibase
  mattr_accessor :connected, instance_accessor: false
  self.connected = false

  def self.exec(key)
    # todo add key check
    @config = Multibase::Config.new key, Multibase::Railtie.database_configuration[key]
    @config.apply
    # binding.pry
    yield
  end
end