require "rubygems"
require "active_record"

database_yaml = IO.read('conf/database.yml')
databases = YAML::load(database_yaml)
ActiveRecord::Base.establish_connection(databases["development"])

#find and load all migrations
Dir.glob("db/migrations/*.rb").each do |file|
  load(file) unless file ==$0
end

#run the migration
Setup.new
InitValidator.new
SetValidator.new