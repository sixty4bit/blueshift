require 'spec_helper'

describe Blueshift do
  it 'has a version number' do
    expect(Blueshift::VERSION).not_to be nil
  end

  describe '.migration' do
    it { expect(Blueshift.migration { up {}; down {}; redup {}; reddown {} }).to be_a(Blueshift::Migration) }
  end
end
