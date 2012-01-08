# coding:utf-8
#
#   this is berlinracingteam.de, a sinatra application
#   it is copyright (c) 2009-2012 danilo braband (danilo @ berlinracingteam,
#   then a dot and a 'de')
#


#
# Tests
#

task :default => :test
task :test do
  require 'fileutils'
  require 'rake/testtask'

  # copy actual database file aside for testing
  FileUtils.cp 'db/local.db', 'db/test.db'

  Rake::TestTask.new do |t|
    t.libs << 'test'
    t.pattern = 'test/test_*.rb'
    t.verbose = true
  end

end


#
# Install/Uninstall
#

task :uninstall do
  system "rvm", "--force", "gemset", "empty"
  File.unlink "Gemfile.lock"
end

task :install do
  system "gem", "install", "bundler"
  system "bundle", "install", "--without", "production"
end


#
# Environment
#

task :environment do
  require File.join(File.dirname(__FILE__), 'env.rb')
end


namespace "db" do

  task :prepare do
    require './app'
    DataMapper::Logger.new($stdout, :debug) unless RACK_ENV == 'production'
    DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:db/local.db?encoding=utf8')
  end

  desc 'Auto-migrate the database (destroys data)'
  task :bootstrap => :environment do
    require 'dm-migrations'
    puts "Bootstrapping database..."
    DataMapper.auto_migrate!
  end

  desc 'Auto-upgrade the database (preserves data)'
  task :migrate => :environment do
    require 'dm-migrations'
    puts "Migrating database..."
    DataMapper.auto_upgrade!
  end

  desc 'Upgrade the database tables.'
  task :upgrade => :prepare do
    adapter = DataMapper.repository(:default).adapter
    adapter.execute('ALTER TABLE news ADD COLUMN `teaser` text NOT NULL DEFAULT \'\';')
    adapter.execute('ALTER TABLE news ADD COLUMN `event_id` integer;')
    adapter.execute('INSERT INTO news (date, title, message, slug, event_id, person_id, created_at, updated_at) SELECT r.date, e.title, r.text, e.slug, r.event_id, r.person_id, r.created_at, r.updated_at FROM reports AS r JOIN events AS e ON r.event_id = e.id;')
    adapter.execute('DELETE FROM reports;')
  end

  desc 'Pull database from heroku'
  task :pull do
    system "heroku", "db:pull", "sqlite://db/local.db?encoding=utf8"
  end

  desc 'Push database to heroku'
  task :push do
    system "heroku", "db:push", "sqlite://db/local.db?encoding=utf8"
  end

end

