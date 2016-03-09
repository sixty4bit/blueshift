require 'blueshift/railtie' if defined?(Rails)
require 'blueshift/version'
require 'blueshift/migration'
require 'sequel'
require 'sequel/adapters/redshift'

module Blueshift
  def self.migration(&block)
    Blueshift::Migration.new(&block)
  end
end
