require 'pg'
begin; require './db/config.rb'; rescue LoadError; end

module DB
  def self.connect env=nil
    if ENV['DATABASE_URL']
      uri  = URI.parse ENV['DATABASE_URL']
      opts = {
        'host'     => uri.host,
        'user'     => uri.user,
        'password' => uri.password,
        'dbname'   => uri.path.split('/')[1]
      }
    else
      opts = DB::Config[env || settings.environment.to_s]
    end
    PG::Connection.new opts
  end
end
