require 'blueshift/railtie' if defined?(Rails)
require 'blueshift/version'
require 'blueshift/migration'
require 'sequel'
require 'sequel/adapters/redshift'
require 'sequel/extensions/schema_dumper_ext'

module Blueshift
  def self.migration(&block)
    Blueshift::Migration.new(&block)
  end
end
