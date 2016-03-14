require 'spec_helper'

PGDB.extension :schema_dumper

RSpec.describe Sequel::Postgres do
  describe '#create_table' do
    describe 'column types' do
      describe 'string uuid' do
        it 'supports fixed-width string uuid columns' do
          sql = 'CREATE TABLE "chocolates" ("id" char(36) NOT NULL)'
          expect(PGDB).to receive(:execute_ddl).with(sql)

          PGDB.create_table :chocolates do
            Suuid :id
          end
        end
      end
    end
  end

  describe 'schema dumper' do
    subject { PGDB.dump_table_schema(:apples) }

    let(:create_macro) do
      ['create_table!(:apples) do',
       '  String :crunchiness, :text=>true',
       '  column :id, :uuid',
       '  Suuid :foreign_table_id, :null=>false',
       'end'].join("\n")
    end

    before do
      PGDB.create_table!(:apples, sortkeys: [:crunchiness]) do
        String :crunchiness
        column :id, :uuid
        Suuid :foreign_table_id
      end
    end

    it { is_expected.to eq create_macro }
  end
end
