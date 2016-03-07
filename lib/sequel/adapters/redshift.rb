require 'sequel/adapters/postgres'

module Sequel
  module Redshift
    include Postgres

    class Database < Postgres::Database
      set_adapter_scheme :redshift
      SORTSTYLES = [:compound, :interleaved].freeze
      DISTSTYLES = [:even, :key, :all].freeze

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

      private

      def create_table_sql(name, generator, options)
        validate_options!(options)
        super.tap do |sql|
          sql << diststyle_sql(options)
          sql << distkey_sql(options)
          sql << sortstyle_sql(options)
        end
      end

      def diststyle_sql(options)
        if options[:diststyle]
          " DISTSTYLE #{options[:diststyle].to_s.upcase}"
        end.to_s
      end

      def distkey_sql(options)
        if options[:distkey]
          " DISTKEY (#{options[:distkey]})"
        end.to_s
      end

      def sortstyle_sql(options)
        if options[:sortkeys]
          style = options[:sortstyle].to_s.upcase
          " #{style} SORTKEY (#{Array(options[:sortkeys]).join(', ')})".squeeze(' ')
        end.to_s
      end

      def validate_options!(options)
        raise ArgumentError, 'sortstyle must be one of :compound or :interleaved' if invalid?(options[:sortstyle], SORTSTYLES)
        raise ArgumentError, 'diststyle must be one of :even, key, or :all' if invalid?(options[:diststyle], DISTSTYLES)
      end

      def invalid?(value, allowed)
        value && !allowed.include?(value)
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
