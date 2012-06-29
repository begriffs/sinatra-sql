require 'rake'
require 'pg'
require './db/config.rb'

task 'db:create' do
  DB::Config.each do |env, opts|
    if opts[:dbname]
      sh "createdb #{opts[:dbname]}"
      sql env, <<-eoq
        create table schema_info
          (version integer not null check (version >= 0))
      eoq
      sql env, "insert into schema_info (version) values (0)"
    end
  end
end

task 'db:drop' do
  DB::Config.each_value { |opts| sh "dropdb #{opts[:dbname]}" if opts[:dbname] }
end

task :migration do
  sh "touch db/#{Time.now.to_i}.{up,down}.sql"
end

task 'db:migrate', :ver, :env do |t, args|
  env       = args['env'] || 'development'
  ms        = available_migrations
  to_ver    = args['ver'] || ms.last
  cur_ver   = current_schema_version env
  direction = to_ver >= cur_ver ? 'up' : 'down'
  apply_migrations migration_path(ms, cur_ver, to_ver), direction, env
end

def apply_migrations migrations, direction, env
  begin
    sql 'begin', env
    migrations.each do |m|
      puts "Migrating #{m} #{direction}"
      sql File.open("db/#{m}.#{direction}.sql", "r").read, env
      sql 'update schema_info set version=$1', env, [m]
    end
    sql 'commit', env
  rescue Exception => e
    puts "Failed, rolling back"
    puts e.message
    sql 'rollback', env
  end
end

def available_migrations direction='up'
  migrations = Dir.glob "db/*.#{direction}.sql"
  migrations.map! {|f| File.basename(f, ".#{direction}.sql")}
  migrations.sort.uniq
end

def migration_path migrations, from, to
  if migrations.include? from
    migrations.reverse! if from > to
    ends     = [from, to].map { |i| migrations.find_index i }
    min, max = ends.min, ends.max
    migrations[min..max][1..-1]
  else
    migrations.select { |m| m <= to }
  end
end

def sql s, env='development', args=[]
  $db ||= Hash.new
  $db[env] ||= PG::Connection.new DB::Config[env]
  $db[env].exec s, args
end

def current_schema_version env
  sql('select version from schema_info', env).first['version']
end
