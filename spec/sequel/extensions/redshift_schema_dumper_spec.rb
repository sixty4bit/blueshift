require 'spec_helper'

DB.extension :redshift_schema_dumper

describe Sequel::Redshift::SchemaDumper do
  let(:options) { {distkey: :region, sortkeys: [:colour, :crunchiness]} }
  let(:extra) { proc {} }
  let(:extra_output) { nil }
  let(:create_macro) do
    [create_table,
     '  String :region, :size=>255, :null=>false',
     '  String :crunchiness, :size=>255',
     '  String :colour, :size=>255',
     '  Suuid :field_id, :null=>false',
     *extra_output,
     'end'].join("\n")
  end

  before do
    extra_macro = extra
    DB.create_table!(:apples, options) do
      String :region, null: false
      String :crunchiness
      String :colour
      Suuid  :field_id, null: false

      instance_eval(&extra_macro)
    end
  end

  describe '#dump_table_schema' do
    subject { DB.dump_table_schema(:apples) }

    context 'with distkey and sortkeys' do
      let(:create_table) { 'create_table!(:apples, :distkey=>:region, :sortkeys=>[:colour, :crunchiness]) do' }
      it 'should output the distkey and sortkeys' do
        is_expected.to eq create_macro
      end
    end

    context 'no diskey or sortkeys' do
      let(:options) { {} }
      let(:create_table) { 'create_table!(:apples) do' }
      it { is_expected.to eq create_macro }
    end

    context 'only with diststyle' do
      let(:options) { {diststyle: :all} }
      let(:create_table) { 'create_table!(:apples, :diststyle=>:all) do' }
      it { is_expected.to eq create_macro }
    end

    context 'with sortstyle' do
      let(:options) { {distkey: :region, sortkeys: [:colour, :region, :crunchiness], sortstyle: :interleaved} }
      let(:create_table) { 'create_table!(:apples, :distkey=>:region, :sortkeys=>[:colour, :region, :crunchiness], :sortstyle=>:interleaved) do' }
      it { is_expected.to eq create_macro }
    end

    context 'with composite primary keys' do
      let(:create_table) { 'create_table!(:apples) do' }
      let(:options) { {} }
      let(:extra) { proc { primary_key [:region, :field_id] } }
      let(:extra_output) { "  \n  primary_key [:region, :field_id]" }

      it { is_expected.to eq create_macro }
    end

    context 'schema_migrations table' do
      subject { DB.dump_table_schema(:schema_migrations) }
      before do
        DB.drop_table?(:apples)
        DB.create_table!(:schema_migrations) { String :filename, primary_key: true }
      end

      let(:create_macro) { "create_table!(:schema_migrations) do\n  String :filename, :size=>255, :null=>false\n  \n  primary_key [:filename]\nend" }
      it { is_expected.to eq create_macro }
    end
  end

  describe '#dump_schema_migration' do
    subject { DB.dump_schema_migration }

    it 'should not blow up' do
      expect(subject).to be_a String
    end

    it 'should not have any trailing whitespaces' do
      subject.each_line do |line|
        expect(line).to_not end_with(/\s+\n/)
      end
    end

    it 'should maintain sequential newlines' do
      expect(subject).to match(/\n\n *primary_key \[/)
    end
  end
end
