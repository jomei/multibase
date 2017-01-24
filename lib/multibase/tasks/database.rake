namespace :db do
  connections = Multibase::Railtie.database_configuration.keys
  binding.pry
  namespace :second_base do
    task :test do
      p 'teststs!!'
      binding.pry
    end
  end
end