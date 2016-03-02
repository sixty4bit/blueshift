require 'spec_helper'

RSpec.describe Sequel::Redshift do
  it { is_expected.to include Sequel::Postgres }

  describe '#create_table' do
    describe 'sortkeys' do
      let(:sql) { 'CREATE TABLE "foos" () SORTKEY (hello)' }

      it 'accepts a :sortkeys option' do
        expect(DB).to receive(:execute_ddl).with(sql)

        DB.create_table :foos, sortkeys: :hello
      end
    end

    context 'multiple sortkeys' do
      it 'accepts multiple sortkeys' do
        sql = 'CREATE TABLE "foos" () SORTKEY (hello, world)'
        expect(DB).to receive(:execute_ddl).with(sql)

        DB.create_table :foos, sortkeys: [:hello, :world]
      end
    end
  end

  describe 'sortstyle' do
    it 'accepts a sortstyle option with sortkeys' do
      sql = 'CREATE TABLE "foos" () INTERLEAVED SORTKEY (hello)'
      expect(DB).to receive(:execute_ddl).with(sql)
      DB.create_table :foos, sortkeys: :hello, sortstyle: :interleaved
    end

    it 'accepts a compound sortstyle' do
      sql = 'CREATE TABLE "foos" () COMPOUND SORTKEY (hello)'
      expect(DB).to receive(:execute_ddl).with(sql)
      DB.create_table :foos, sortkeys: :hello, sortstyle: :compound
    end

    it 'does not accept other sortstyles' do
      expect { DB.create_table :foos, sortkeys: :hello, sortstyle: :other }.to raise_error(ArgumentError, 'only :compound and :interleaved sortstyles are allowed')
    end
  end
end
