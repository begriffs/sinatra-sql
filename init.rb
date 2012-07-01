require './db/init'

configure do
  set :public_folder, 'public'
end

def sql cmd, *args
  $db ||= DB::connect
  $db.exec cmd, args
end
