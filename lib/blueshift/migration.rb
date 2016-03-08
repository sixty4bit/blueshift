require 'sequel'
require 'sequel/extensions/migration'
require 'logger'

module Blueshift
  REDSHIFT_DB = Sequel.connect(ENV.fetch('REDSHIFT_URL'), logger: Logger.new('redshift.log'))
  POSTGRES_DB = Sequel.connect(ENV.fetch('DATABASE_URL'), logger: Logger.new('postgres.log'))

  class Migration
    attr_reader :postgres_migration, :redshift_migration
    MIGRATION_DIR = File.join(Dir.pwd, 'db/migrations')

    def initialize(&block)
      @postgres_migration = Sequel::SimpleMigration.new
      @redshift_migration = Sequel::SimpleMigration.new

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

    def self.run!
      Sequel::Migrator.run(POSTGRES_DB, MIGRATION_DIR, column: :postgres_version)
      Sequel::Migrator.run(REDSHIFT_DB, MIGRATION_DIR, column: :redshift_version)
    end

    private

    def validate!
      unless [postgres_migration.up, postgres_migration.down, redshift_migration.up, redshift_migration.down].all?
        raise ArgumentError, 'must declare blocks for up, down, redup, and reddown'
      end
    end
  end
end
