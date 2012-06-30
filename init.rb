require './db/config.rb' rescue LoadError # won't exist on Heroku

configure do
  opts = ENV['DATABASE_URL'] || DB::Config[settings.environment.to_s]
  $db  = PG::Connection.new opts

  set :public_folder, 'public'
end

def sql cmd, *args
  $db.exec cmd, args
end
