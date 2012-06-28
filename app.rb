require 'sinatra'
require 'pg'
require 'psych'

require './init'

get '/' do
  sql('select version from schema_info').first['version']
end
