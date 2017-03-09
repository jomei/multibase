module Multibase
  mattr_accessor :connected, instance_accessor: false

  def self.exec(key)
    if @config.nil? || @config.key != key
      @config = Multibase::Config.new key, Multibase::Railtie.database_configuration[key]
      @config.apply
    end
    yield
  end
end
