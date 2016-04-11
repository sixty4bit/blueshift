require 'sequel'
require 'sequel/extensions/migration'
require 'logger'

module Blueshift
  REDSHIFT_DB = Sequel.connect(ENV.fetch('REDSHIFT_URL', 'redshift://'), logger: Logger.new('redshift.log'))
  POSTGRES_DB = Sequel.connect(ENV.fetch('DATABASE_URL', 'postgres://'), logger: Logger.new('postgres.log'))

  class Migration
    attr_reader :postgres_migration, :redshift_migration, :use_transactions
    MIGRATION_DIR = File.join(Dir.pwd, 'db/migrations')
    SCHEMA_TABLE  = :schema_migrations
    SCHEMA_COLUMN = :filename

    def initialize(&block)
      @postgres_migration = Sequel::SimpleMigration.new
      @redshift_migration = Sequel::SimpleMigration.new
      @use_transactions = true

      Sequel::Migration.descendants << self
      instance_eval(&block)
      validate!
    end

    def up(&block)
      postgres_migration.up = block
    end

    def down(&block)
      postgres_migration.down = block
    end

    def redup(&block)
      redshift_migration.up = block
    end

    def reddown(&block)
      redshift_migration.down = block
    end

    def apply(db, direction)
      if db.is_a?(Sequel::Redshift::Database)
        redshift_migration.apply(db, direction)
      else
        postgres_migration.apply(db, direction)
      end
    end

    class << self
      def run_pg!
        Sequel::Migrator.run(POSTGRES_DB, MIGRATION_DIR)
      end

      def run_redshift!
        Sequel::Migrator.run(REDSHIFT_DB, MIGRATION_DIR)
      end

      def run_both!
        run_pg!
        run_redshift!
      end

      def insert_into_schema_migrations(db)
        ds = schema_dataset(db)
        ds.delete
        migration_files = Dir["#{MIGRATION_DIR}/*"]
        migration_files.each do |path|
          f = File.basename(path)
          ds.insert(SCHEMA_COLUMN=>f)
        end
      end

      def schema_dataset(db)
        ds = db.from(SCHEMA_TABLE)
        unless db.table_exists?(SCHEMA_TABLE)
          db.create_table(SCHEMA_TABLE) { String SCHEMA_COLUMN, primary_key: true }
        end
        ds
      end
    end

    private

    def validate!
      unless [postgres_migration.up, postgres_migration.down, redshift_migration.up, redshift_migration.down].all?
        raise ArgumentError, 'must declare blocks for up, down, redup, and reddown'
      end
    end
  end
end
