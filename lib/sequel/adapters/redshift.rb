require 'sequel/adapters/postgres'

module Sequel
  module Redshift
    include Postgres

    class Database < Postgres::Database
      set_adapter_scheme :redshift

      def column_definition_primary_key_sql(sql, column)
        result = super
        result << ' IDENTITY' if result
        result
      end

      def serial_primary_key_options
        # redshift doesn't support serial type
        super.merge(serial: false)
      end

      def connection_configuration_sqls
        []
      end

      def create_table_sql(name, generator, options)
        super.tap do |sql|
          sql << " #{sortstyle_sql(options[:sortstyle])}" if options[:sortstyle]
          sql << " SORTKEY (#{Array(options[:sortkeys]).join(', ')})" if options[:sortkeys]
        end
      end

      def sortstyle_sql(style)
        raise Arg
        style.to_s.upcase
      end
    end

    class Dataset < Postgres::Dataset
      Database::DatasetClass = self

      # Redshift doesn't support RETURNING statement
      def insert_returning_sql(sql)
        # do nothing here
        sql
      end
    end
  end
end
