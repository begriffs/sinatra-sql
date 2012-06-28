configure do
  conf = Psych.load File.open("db/config.yml", "r").read
  env  = settings.environment.to_s
  $db  = PG::Connection.new conf[env] if conf[env].has_key? 'dbname'
end

def sql cmd, *args
  $db.exec cmd, args
end
