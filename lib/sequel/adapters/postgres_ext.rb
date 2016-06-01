require 'sequel/adapters/postgres'
require 'blueshift/uuid'

module Sequel
  module Postgres
    class Database
      def type_literal_generic_suuid(column)
        column[:fixed] = true
        column[:size] = 36
        column[:null] ||= false
        type_literal_generic_string(column)
      end
    end
  end
end
