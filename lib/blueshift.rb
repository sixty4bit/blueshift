require "blueshift/version"
require 'sequel'
require 'sequel/adapters/redshift'

module Blueshift
  # create_table :tests, diststyle: :key, sortkeys:
end

__END__

+create_table+ Options:

:diststyle => :even, :key, :all

    when diststyle is specified, must include a :distkey

:distkey => symbol

    when specified, set :diststyle to :key unless otherwise specified

:sortkeys => symbol or array

:sortstyle => :compound (default) or :interleaved

    Compound: max 400 sortkeys
    Interleaved: max 8 sortkeys
