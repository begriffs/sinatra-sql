require 'sinatra'
require 'pg'
require './init'

get '/' do
  sql('select version from schema_info').first['version']
end
