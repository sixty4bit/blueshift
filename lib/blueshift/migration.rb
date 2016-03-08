require 'active_record'
require 'sequel'
require 'sequel/extensions/migration'

module Blueshift
  REDSHIFT_DB = Sequel.connect(ENV.fetch('REDSHIFT_URL'))
  POSTGRES_DB = Sequel.connect(ENV.fetch('DATABASE_URL'))

  class Migration
    attr_reader :postgres_migration, :sequel_migration
    MIGRATION_DIR = 'db/migrate'

    def initialize(&block)
      @postgres_migration = ActiveRecord::Migration.new # TODO remove AR dependency
      @redshift_migration = Sequel::SimpleMigration.new
      @migrate_redshift = true
      instance_eval(&block)
    end

    def up(&block)
      postgres_migration.define_singleton_method(:up, &block)
      redup(&block) unless migrate_redshift?
    end

    def down(&block)
      postgres_migration.define_singleton_method(:down, &block)
      redup(&block) unless migrate_redshift?
    end

    def redup(&block)
      redshift_migration.up = block
    end

    def reddown(&block)
      redshift_migration.down = block
    end

    def pg_only!
      self.migrate_redshift = false
      redshift_migration.up = proc {}
      redshift_migration.down = proc {}
    end

    def self.run
      Sequel::Migration.run(POSTGRES_DB, MIGRATION_DIR, column: :postgres_version)
      Sequel::Migration.run(REDSHIFT_DB, MIGRATION_DIR, column: :redshift_version)
    end

    private

    def migrate_redshift?
      @migrate_redshift
    end
  end

  def self.migration(&block)
    Blueshift::Migration.new(&block)
  end
end
