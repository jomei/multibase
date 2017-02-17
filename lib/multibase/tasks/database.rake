namespace :db do
  #todo: add tasks for all databases
  connections = Multibase::Railtie.database_configuration.keys
  connections.each do |connection_name|
    namespace connection_name.to_sym do
      task :create do
        Multibase.exec(connection_name) { Rake::Task['db:create'].execute }
      end

      task :drop do
        Multibase.exec(connection_name) { Rake::Task['db:drop'].execute }
      end

      task :purge do
        Multibase.exec(connection_name) { Rake::Task['db:purge'].execute }
      end

      task :migrate do
        Multibase.exec(connection_name) { Rake::Task['db:migrate'].execute }
      end

      namespace :migrate do

        task :redo => ['db:load_config'] do
          Multibase.exec(connection_name) { Rake::Task['db:migrate:redo'].execute }
        end

        task :up => ['db:load_config'] do
          Multibase.exec(connection_name) { Rake::Task['db:migrate:up'].execute }
        end

        task :down => ['db:load_config'] do
          Multibase.exec(connection_name) { Rake::Task['db:migrate:down'].execute }
        end

        task :status => ['db:load_config'] do
          Multibase.exec(connection_name) { Rake::Task['db:migrate:status'].execute }
        end

      end

      task :rollback => ['db:load_config'] do
        Multibase.exec(connection_name) { Rake::Task['db:rollback'].execute }
      end

      task :forward => ['db:load_config'] do
        Multibase.exec(connection_name) { Rake::Task['db:forward'].execute }
      end

      task :abort_if_pending_migrations do
        Multibase.exec(connection_name) { Rake::Task['db:abort_if_pending_migrations'].execute }
      end

      task :version => ['db:load_config'] do
        Multibase.exec(connection_name) { Rake::Task['db:version'].execute }
      end

      namespace :schema do

        task :load do
          Multibase.exec(connection_name) { Rake::Task['db:schema:load'].execute }
        end

        namespace :cache do

          task :dump do
            Multibase.exec(connection_name) { Rake::Task['db:schema:cache:dump'].execute }
          end

        end

      end

      namespace :structure do

        task :load do
          Multibase.exec(connection_name) { Rake::Task['db:structure:load'].execute }
        end

      end

      namespace :test do

        task :purge do
          Multibase.exec(connection_name) { Rake::Task['db:test:purge'].execute }
        end

        task :load_schema do
          Multibase.exec(connection_name) { Rake::Task['db:test:load_schema'].execute }
        end

        task :load_structure do
          Multibase.exec(connection_name) { Rake::Task['db:test:load_structure'].execute }
        end

        task :prepare do
          Multibase.exec(connection_name) { Rake::Task['db:test:prepare'].execute }
        end
      end

    end
  end
end

%w{
  create:all create drop:all drop purge:all purge
  migrate migrate:status abort_if_pending_migrations
  schema:load schema:cache:dump structure:load
  test:purge test:load_schema test:load_structure test:prepare
}.each do |name|

  task = Rake::Task["db:#{name}"] rescue nil
  next unless task
  task.enhance do
    Rake::Task["db:load_config"].invoke
    Rake::Task["db:lite:#{name}"].invoke
  end
end