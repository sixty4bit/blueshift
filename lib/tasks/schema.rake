require 'dotenv'
Dotenv.load
require 'fileutils'
require 'blueshift'

path = File.join(Dir.pwd, 'db')
logger = Logger.new(STDOUT)

Blueshift::POSTGRES_DB.logger = logger
Blueshift::REDSHIFT_DB.logger = logger

task :ensure_db_dir do
  FileUtils.mkdir_p(path)
end

namespace :pg do
  namespace :schema do
    desc 'Dumps the Postgres schema to a file'
    task :dump => :ensure_db_dir do
      Blueshift::POSTGRES_DB.extension :redshift_schema_dumper
      File.open(File.join(path, 'schema.rb'), 'w') { |f| f << Blueshift::POSTGRES_DB.dump_schema_migration(same_db: true) }
    end

    desc 'Loads the Postgres schema from the file to the database'
    task :load => :ensure_db_dir do
      eval(File.read(File.join(path, 'schema.rb'))).apply(Blueshift::POSTGRES_DB, :up)
      puts 'loaded schema into Postgres'
    end
  end

  desc 'Runs migrations for Postgres'
  task :migrate do
    Blueshift::Migration.run_pg!
  end
end


namespace :redshift do
  namespace :schema do
    desc 'Dumps the Postgres schema to a file'
    task :dump => :ensure_db_dir do
      Blueshift::REDSHIFT_DB.extension :redshift_schema_dumper
      File.open(File.join(path, 'schema_redshift.rb'), 'w') { |f| f << Blueshift::REDSHIFT_DB.dump_schema_migration(same_db: true) }
    end

    desc 'Loads the Postgres schema from the file to the database'
    task :load => :ensure_db_dir do
      eval(File.read(File.join(path, 'schema_redshift.rb'))).apply(Blueshift::REDSHIFT_DB, :up)
      puts 'loaded schema into Redshift'
    end
  end

  desc 'Runs migrations for Redshift'
  task :migrate do
    Blueshift::Migration.run_redshift!
  end
end

namespace :blueshift do
  desc 'Runs migrations for both Postgres and Redshift'
  task :migrate do
    puts 'Running migrations for Postgres and Redshift...', ''
    Blueshift::Migration.run_both!
  end
end

