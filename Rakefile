require 'rake/dsl_definition'
require 'rake'
require 'rake/rdoctask'
#require 'spec/rake/spectask'
require 'cucumber/rake/task'

desc "Cucumber"
task :cucumber do
  Cucumber::Rake::Task.new
end

desc "rspec"
task :rspec do
  Spec::Rake::SpecTask.new do |t|
    t.libs << 'lib'
    t.libs << 'spec'
  end
end

HOME = File.expand_path(File.dirname(__FILE__))

# map local users to server users

if ENV["USER"] == "Carol"
  user = "cchou"
else
  user = ENV["USER"]
end

desc "Hit the restart button for apache/passenger, pow servers"
task :restart do
  sh "touch #{HOME}/tmp/restart.txt"
end

# Build local bundled Gems; 

desc "Gem bundles"
task :bundle do
  sh "rm -rf #{HOME}/bundle #{HOME}/.bundle #{HOME}/Gemfile.lock"
  sh "mkdir -p #{HOME}/bundle"
  sh "cd #{HOME}; bundle --gemfile Gemfile install --path bundle"
end


desc "deploy to darchive's production site (describe.fda.fcla.edu)"
task :darchive do
    sh "cap deploy -S target=darchive.fcla.edu:/opt/web-services/sites/describe -S who=#{user}:#{user}"
end

desc "deploy to development site (describe.retsina.fcla.edu)"
task :retsina do
    sh "cap deploy -S target=retsina.fcla.edu:/opt/web-services/sites/describe -S who=daitss:daitss"
end

desc "deploy to development site (describe.marsala.fcla.edu)"
task :marsala do
	    sh "cap deploy -S target=marsala.fcla.edu:/opt/web-services/sites/describe -S who=daitss:daitss"
end

desc "deploy to ripple's test site (describe.ripple.fcla.edu)"
task :ripple do
    sh "cap deploy -S target=ripple.fcla.edu:/opt/web-services/sites/describe -S who=#{user}:#{user}"
end

desc "deploy to tarchive's coop (describe.tarchive.fcla.edu?)"
task :tarchive_coop do
    sh "cap deploy -S target=tarchive.fcla.edu:/opt/web-services/sites/coop/describe -S who=#{user}:#{user}"
end

defaults = [:restart]

task :default => defaults
