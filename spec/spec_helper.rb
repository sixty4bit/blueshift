Bundler.require(:test)
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'dotenv'
Dotenv.load
require 'blueshift'


DB = Sequel.connect('redshift://localhost/db')


