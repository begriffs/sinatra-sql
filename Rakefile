require 'rake'
require 'pg'
include Rake::DSL
require './db/config.rb' rescue LoadError # won't exist on Heroku

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

task 'db:create', :env do |t, args|
  env  = args['env'] || 'development'
  if !ENV['DATABASE_URL']
    opts = DB::Config[ env ]
    sh "createdb #{opts['dbname']}"
  end
  sql env, <<-eoq
    create table schema_info
      (version integer not null check (version >= 0))
  eoq
  sql env, "insert into schema_info (version) values (0)"
end

task 'db:drop', :env do |t, args|
  return if ENV['DATABASE_URL']
  env  = args['env'] || 'development'
  opts = DB::Config[ env ]
  $db[env].finish if $db && $db[env]
  sh "dropdb #{opts['dbname']}"
end

task :migration do
  sh "touch db/#{Time.now.to_i}.{up,down}.sql"
end

task 'db:migrate', :ver, :env do |t, args|
  env       = args['env'] || 'development'
  ms        = available_migrations
  to_ver    = args['ver'] || ms.last
  cur_ver   = current_schema_version env
  direction = cur_ver <= to_ver ? 'up' : 'down'
  if apply_migrations migration_path(ms, cur_ver, to_ver), direction, env
    sql env, 'update schema_info set version=$1', to_ver
  end
end

def apply_migrations migrations, direction, env
  return true if migrations.empty?
  begin
    sql env, 'begin'
    (migrations.select { |m| m != '0' }).each do |m|
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
  migrations.sort.unshift('0').uniq
end

def migration_path migrations, from, to
  fail "Unknown migration source #{to}" unless migrations.include? from
  fail "Unknown migration target #{to}" unless migrations.include? to
  migrations.reverse! if from > to
  ends     = [from, to].map { |i| migrations.find_index i }
  min, max = ends.min, ends.max
  migrations[min..max] - [from <= to ? from : to]
end

def sql env, cmd, *args
  $db ||= Hash.new
  if !$db.has_key?(env) || $db[env].finished?
    $db[env] = PG::Connection.new ENV['DATABASE_URL'] || DB::Config[env]
  end
  $db[env].exec cmd, args
end

def current_schema_version env
  sql(env, 'select version from schema_info').first['version']
end
