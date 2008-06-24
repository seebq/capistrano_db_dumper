# tasks for dumbing your production db

set :domain, "example.com"
set :user, "deploy"
set :database_username, "root"
set :database_password, ""

namespace :db_dumper do
  desc "Exports the production db to the home directory of user" 
  task :mysql_dump, :roles => [:db], :only => { :primary => true } do
    run "mysqldump -u #{database_username ? database_username : user} --password=#{database_password ? database_password : password} #{application}_production > production.sql"
    run "tar -cvzf production.tar.gz production.sql"
  end

  desc 'Grab a dump of the production database on the server and places it in db/production.sql.'
  task :fetch, :roles => [:db], :only => { :primary => true } do
    `scp #{user}@#{domain}:production.tar.gz db/production.tar.gz`
    `cd db/ && tar -xvzf production.tar.gz && cd ..`
  end

  desc 'Loads the database dump of file db/production.sql into development.'
  task :mysql_load, :roles => [:db], :only => { :primary => true } do
    `mysql -u root #{application}_development < db/production.sql`
  end

  desc 'Grabs a dump of the production database from the server and imports the data into the local development database.'
  task :import, :roles => [:db], :only => { :primary => true } do
    db_dumper.mysql_dump
    db_dumper.fetch
    db_dumper.mysql_load
  end

end