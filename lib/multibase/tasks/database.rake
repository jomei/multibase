namespace :db do
  connections = Multibase::Railtie.database_configuration.keys
  connections.each do |connection_name|
    namespace connection_name.to_sym do
      task :create do
        task :all do
          Multibase.exec(connection_name) { Rake::Task['db:create:all'].execute }
        end

        Multibase.exec(connection_name) { Rake::Task['db:create'].execute }
      end

      namespace :drop do
        task :all do
          Multibase.exec(connection_name) { Rake::Task['db:drop:all'].execute }
        end
      end

      namespace :purge do
        task :all do
          Multibase.exec(connection_name) { Rake::Task['db:purge:all'].execute }
        end
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