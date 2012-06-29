require './db/config.rb'

configure do
  opts = DB::Config[settings.environment]
  $db  = PG::Connection.new opts if opts.has_key? 'dbname'

  set :public_folder, 'public'
end

def sql cmd, *args
  $db.exec cmd, args
end
