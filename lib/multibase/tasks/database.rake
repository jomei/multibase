namespace :db do
  # connections = Multibase::Railtie.database_configuration.keys
  namespace :postgre_db do
    task :create do
      Multibase.exec('postgre_db') { Rake::Task['db:create'].execute}
    end
  end
end