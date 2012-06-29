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
  cur_ver   = sql('select version from schema_info', env).first['version']
  direction = to_ver >= cur_ver ? 'up' : 'down'
  if apply_migrations migration_path(ms, cur_ver, to_ver), direction, env
    sql env, 'update schema_info set version=$1', to_ver
  end
end

def apply_migrations migrations, direction, env
  begin
    sql env, 'begin'
    (migrations.select { |m| m != 0 }).each do |m|
      puts "Migrating #{m} #{direction}"
      sql env, File.open("db/#{m}.#{direction}.sql", "r").read
    end
    sql env, 'commit'
    return true
  rescue Exception => e
    puts "Failed, rolling back"
    puts e.message
    sql env, 'rollback'
    return false
  end
end

def available_migrations direction='up'
  migrations = Dir.glob "db/*.#{direction}.sql"
  migrations.map! {|f| File.basename(f, ".#{direction}.sql")}
  migrations.sort.unshift(0).uniq
end

def migration_path migrations, from, to
  fail "Unknown migration #{to}" unless migrations.include? to
  migrations.reverse! if from > to
  ends     = [from, to].map { |i| migrations.find_index i }
  min, max = ends.min, ends.max
  migrations[min..max][1..-1]
end

def sql env, s, *args
  $db ||= Hash.new
  $db[env] ||= PG::Connection.new DB::Config[env]
  $db[env].exec s, args
end
