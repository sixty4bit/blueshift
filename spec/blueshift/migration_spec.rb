require 'spec_helper'

describe Blueshift::Migration do
  let(:up_block) { proc { 'up' } }
  let(:down_block) { proc { 'down' } }
  let!(:redup_block) { proc { 'redup' } }
  let!(:reddown_block) { proc { 'reddown' } }

  before do
    Sequel::Migration.descendants.clear
  end

  subject do
    up_blk = up_block
    down_blk = down_block
    redup_blk = redup_block
    reddown_blk = reddown_block

    Blueshift.migration do
      up &up_blk
      down &down_blk
      redup &redup_blk
      reddown &reddown_blk
    end
  end

  describe '.new' do
    it 'should assign the redshift commands individually' do
      expect(subject.postgres_migration.up).to eq up_block
      expect(subject.redshift_migration.up).to eq redup_block
      expect(subject.postgres_migration.down).to eq down_block
      expect(subject.redshift_migration.down).to eq reddown_block
    end

    it 'appends the migration to the list of Sequel Migrations' do
      expect(Sequel::Migration.descendants).to eq([subject])
    end

    context 'when either redup or reddown is not declared' do
      subject { Blueshift.migration { up {}; down {} } }
      it 'should raise an exception' do
        expect { subject }.to raise_error(ArgumentError, 'must declare blocks for up, down, redup, and reddown')
      end
    end
  end

  describe '#apply' do
    context 'when applying to a Redshift database' do
      it 'should call the Redshift migrations' do
        expect(subject.redshift_migration).to receive(:apply).with(Blueshift::REDSHIFT_DB, :up)
        subject.apply(Blueshift::REDSHIFT_DB, :up)
      end

      it 'does not apply the Postgres migration commands' do
        expect(subject.postgres_migration).to_not receive(:apply)
        subject.apply(Blueshift::REDSHIFT_DB, :up)
      end
    end

    context 'when applying to a Postgres database' do
      it 'should call the Redshift migrations' do
        expect(subject.postgres_migration).to receive(:apply).with(Blueshift::POSTGRES_DB, :down)
        subject.apply(Blueshift::POSTGRES_DB, :down)
      end

      it 'does not apply the Redshift migration commands' do
        expect(subject.redshift_migration).to_not receive(:apply)
        subject.apply(Blueshift::POSTGRES_DB, :up)
      end
    end
  end

  describe '.run' do
    it 'should run the migrations for both Postgres and Redshift' do
      expect(Sequel::Migrator).to receive(:run).ordered do |db, dir, options|
        expect(db).to eq(Blueshift::POSTGRES_DB)
        expect(dir).to end_with('db/migrations')
        expect(options).to eq(column: :postgres_version)
      end

      expect(Sequel::Migrator).to receive(:run).ordered do |db, dir, options|
        expect(db).to eq(Blueshift::REDSHIFT_DB)
        expect(dir).to end_with('db/migrations')
        expect(options).to eq(column: :redshift_version)
      end
      Blueshift::Migration.run!
    end
  end
end
