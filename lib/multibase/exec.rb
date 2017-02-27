module Multibase
  mattr_accessor :connected, instance_accessor: false
  self.connected = false

  def self.exec(connection_name)
    @config = Multibase::Config.new connection_name, Multibase::Railtie.database_configuration[connection_name]
    @config.apply
    yield
  end
end