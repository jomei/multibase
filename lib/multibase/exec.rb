module Multibase
  mattr_accessor :connected, instance_accessor: false

  def self.exec(key)
    config = @config[key] if @config
    config ||= Multibase::Config.new key, Multibase::Railtie.database_configuration[key]
    config.apply

    yield
  end
end
