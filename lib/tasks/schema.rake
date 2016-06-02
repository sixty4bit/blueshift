require 'dotenv'
Dotenv.load
require 'fileutils'
require 'blueshift'

path = File.join(Dir.pwd, 'db')
logger = Logger.new(STDOUT)

task :ensure_db_dir do
  FileUtils.mkdir_p(path)
end

namespace :pg do
  namespace :schema do
    desc 'Dumps the Postgres schema to a file'
    task :dump => :ensure_db_dir do
      Blueshift::POSTGRES_DB.extension :schema_dumper
      File.open(File.join(path, 'schema.rb'), 'w') { |f| f << Blueshift::POSTGRES_DB.dump_schema_migration(same_db: false) }
    end

    desc 'Loads the Postgres schema from the file to the database'
    task :load => :ensure_db_dir do
      migration = eval(File.read(File.join(path, 'schema.rb')))
      migration.apply(Blueshift::POSTGRES_DB, :up)
      puts 'loaded schema into Postgres'
      Blueshift::Migration.insert_into_schema_migrations(Blueshift::POSTGRES_DB)
      puts 'inserted schema migrations entries'
    end
  end

  desc 'Runs migrations for Postgres'
  task :migrate do
    Blueshift::POSTGRES_DB.logger = logger
    Blueshift::Migration.run_pg!
    Rake::Task['pg:schema:dump'].invoke
  end

  desc 'Rollback the latest applied migration for Postgres'
  task :rollback do
    Blueshift::Migration.rollback!(:pg)
    Rake::Task['pg:schema:dump'].invoke
  end
end


namespace :redshift do
  namespace :schema do
    desc 'Dumps the Postgres schema to a file'
    task :dump => :ensure_db_dir do
      Blueshift::REDSHIFT_DB.extension :redshift_schema_dumper
      File.open(File.join(path, 'schema_redshift.rb'), 'w') { |f| f << Blueshift::REDSHIFT_DB.dump_schema_migration(same_db: false) }
    end

    desc 'Loads the Postgres schema from the file to the database'
    task :load => :ensure_db_dir do
      migration = eval(File.read(File.join(path, 'schema_redshift.rb')))
      migration.apply(Blueshift::REDSHIFT_DB, :up)
      puts 'loaded schema into Redshift'
      Blueshift::Migration.insert_into_schema_migrations(Blueshift::REDSHIFT_DB)
      puts 'inserted schema migrations entries'
    end
  end

  desc 'Runs migrations for Redshift'
  task :migrate do
    Blueshift::REDSHIFT_DB.logger = logger
    Blueshift::Migration.run_redshift!
    Rake::Task['redshift:schema:dump'].invoke
  end

  desc 'Rollback the latest applied migration for Redshift'
  task :rollback do
    Blueshift::Migration.rollback!(:redshift)
    Rake::Task['pg:schema:dump'].invoke
  end
end

namespace :blueshift do
  desc 'Runs migrations for both Postgres and Redshift. Not really that useful most of the time...'
  task :migrate => ['pg:migrate', 'redshift:migrate'] do
    puts 'Running migrations for Postgres and Redshift...', ''
  end
end

