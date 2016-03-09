require 'dotenv'
Dotenv.load
require 'fileutils'
require 'blueshift'

path = File.join(Dir.pwd, 'db')

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
      eval(File.join(path, 'schema.rb')).apply(Blueshift::POSTGRES_DB, :up)
    end
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
      eval(File.join(path, 'schema_redshift.rb')).apply(Blueshift::REDSHIFT_DB, :up)
    end
  end
end

namespace :blueshift do
  desc 'Runs migrations for both Postgres and Redshift'
  task :migrate do
    puts 'Running migrations for Postgres and Redshift...', ''
    Blueshift::Migration.run!
  end
end

