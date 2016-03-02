$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'blueshift'

DB = Sequel.connect('redshift://localhost/db')
