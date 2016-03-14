require 'sequel/extensions/schema_dumper'
module Sequel
  module SchemaDumper
    alias_method :dump_table_schema_without_force, :dump_table_schema

    def dump_table_schema(table, opts=OPTS)
      dump_table_schema_without_force(table, opts).gsub('create_table(', 'create_table!(')
    end
  end
end
