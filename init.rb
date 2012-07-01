begin; require './db/config.rb'; rescue LoadError; end
require 'uri'

configure do
  if ENV['DATABASE_URL']
    uri = URI.parse ENV['DATABASE_URL']
    opts = {
      'hostname' => uri.host,
      'dbname'   => uri.path.split('/')[1]
    }
  else
    opts = DB::Config[settings.environment.to_s]
  end
  $db = PG::Connection.new opts
  set :public_folder, 'public'
end

def sql cmd, *args
  $db.exec cmd, args
end
