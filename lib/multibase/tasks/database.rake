namespace :db do
  keys = Multibase::Railtie.connection_keys
  keys.each do |key|
    namespace key.to_sym do
      namespace :create do
        task :all do
          Multibase.exec(key) { Rake::Task['db:create:all'].execute }
        end
      end

      task :create do
        Multibase.exec(key) { Rake::Task['db:create'].execute }
      end

      task drop: ['db:load_config'] do
        Multibase.exec(key) { Rake::Task['db:drop'].execute }
      end

      namespace :drop do
        task :all do
          Multibase.exec(key) { Rake::Task['db:drop:all'].execute }
        end
      end

      task :purge do
        Multibase.exec(key) { Rake::Task['db:purge'].execute }
      end

      namespace :purge do
        task :all do
          Multibase.exec(key) { Rake::Task['db:purge:all'].execute }
        end
      end

      task :migrate do
        Multibase.exec(key) { Rake::Task['db:migrate'].execute }
      end

      namespace :migrate do
        task :all do
          Multibase.exec(key) { Rake::Task['db:migrate:all'].execute }
        end
      end

      task :setup do
        Multibase.exec(key) { Rake::Task['db:setup'].execute }
      end

      task :seed do
        Multibase.exec(key) { Rake::Task['db:seed'].execute }
      end

      namespace :migrate do
        task redo: ['db:load_config'] do
          Multibase.exec(key) { Rake::Task['db:migrate:redo'].execute }
        end

        task up: ['db:load_config'] do
          Multibase.exec(key) { Rake::Task['db:migrate:up'].execute }
        end

        task down: ['db:load_config'] do
          Multibase.exec(key) { Rake::Task['db:migrate:down'].execute }
        end

        task status: ['db:load_config'] do
          Multibase.exec(key) { Rake::Task['db:migrate:status'].execute }
        end
      end

      task rollback: ['db:load_config'] do
        Multibase.exec(key) { Rake::Task['db:rollback'].execute }
      end

      task forward: ['db:load_config'] do
        Multibase.exec(key) { Rake::Task['db:forward'].execute }
      end

      task :abort_if_pending_migrations do
        Multibase.exec(key) { Rake::Task['db:abort_if_pending_migrations'].execute }
      end

      task version: ['db:load_config'] do
        Multibase.exec(key) { Rake::Task['db:version'].execute }
      end

      namespace :schema do
        task :load do
          Multibase.exec(key) { Rake::Task['db:schema:load'].execute }
        end

        task :dump do
          Multibase.exec(key) { Rake::Task['db:schema:dump'].execute }
        end

        namespace :cache do
          task :dump do
            Multibase.exec(key) { Rake::Task['db:schema:cache:dump'].execute }
          end
        end
      end

      namespace :structure do
        task :load do
          Multibase.exec(key) { Rake::Task['db:structure:load'].execute }
        end
      end

      namespace :test do
        task :purge do
          Multibase.exec(key) { Rake::Task['db:test:purge'].execute }
        end

        task :load_schema do
          Multibase.exec(key) { Rake::Task['db:test:load_schema'].execute }
        end

        task :load_structure do
          Multibase.exec(key) { Rake::Task['db:test:load_structure'].execute }
        end

        task :prepare do
          Multibase.exec(key) { Rake::Task['db:test:prepare'].execute }
        end
      end
    end
  end
end

%w(
  create:all create drop:all drop purge:all purge
  migrate migrate:status abort_if_pending_migrations
  schema:dump schema:load schema:cache:dump structure:load setup seed
  test:purge test:load_schema test:load_structure test:prepare
).each do |name|
  task = Rake::Task["db:#{name}"]
  next unless task

  task.enhance do
    Rake::Task['db:load_config'].invoke
    Multibase::Railtie.connection_keys.each do |connection|
      Rake::Task["db:#{connection}:#{name}"].invoke
    end
  end
end
