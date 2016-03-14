Sequel.extension :schema_dumper

module Sequel
  module Redshift
    module SchemaDumper
      include Sequel::SchemaDumper

      def dump_table_schema(table, options=OPTS)
        gen = dump_table_generator(table, options)
        commands = [gen.dump_columns, gen.dump_constraints, gen.dump_indexes].reject { |x| x == '' }.join("\n\n")

        "create_table!(#{table.inspect}#{table_options(table, gen, options)}) do\n#{commands.gsub(/^/o, '  ')}\nend"
      end

      def table_options(table, gen, options)
        s = {distkey: table_distkey(table),
         sortkeys: table_sortkeys(table),
         sortstyle: table_sortstyle(table),
         ignore_index_errors: (!options[:same_db] && options[:indexes] != false && !gen.indexes.empty?)
        }.select { |_,v| v }.inspect[1...-1]

        s.empty? ? s : ", #{s}"
      end

      private

      def table_distkey(table)
        key = pg_table_def(table).filter(distkey: true).map(:column).first
        key.to_sym if key
      end

      def table_sortkeys(table)
        keys = sortkey_columns(table).map{ |r| r[:column].to_sym }
        keys unless keys.empty?
      end

      def table_sortstyle(table)
        :interleaved if sortkey_columns(table).any? { |row| row[:sortkey] < 0 }
      end

      def sortkey_columns(table)
        pg_table_def(table).exclude(sortkey: 0).order(Sequel.function(:abs, :sortkey))
      end

      def pg_table_def(table)
        self[:pg_table_def].where(schemaname: 'public', tablename: table.to_s).select(:column, :sortkey)
      end
    end
  end

  Database.register_extension(:redshift_schema_dumper, Redshift::SchemaDumper)
end
