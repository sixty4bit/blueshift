require 'spec_helper'

RSpec.describe Sequel::Postgres do
  describe '#create_table' do
    describe 'column types' do
      describe 'string uuid' do
        it 'supports fixed-width string uuid columns' do
          sql = 'CREATE TABLE "chocolates" ("id" char(36) NOT NULL PRIMARY KEY)'
          expect(PGDB).to receive(:execute_ddl).with(sql)

          PGDB.create_table :chocolates do
            Suuid :id
          end
        end
      end
    end
  end
end
