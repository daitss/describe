# -*- mode:ruby; -*-
#
#  Set deploy target host/filesystem to use from cap command line as so:
#
#  cap deploy  -S target=ripple.fcla.edu:/opt/web-services/sites/describe  
#
#  One can over-ride user and group settings using -S who=user:group

require 'rubygems'
require 'railsless-deploy'
require 'bundler/capistrano'

set :repository,   "git://github.com/daitss/describe.git"
set :scm,          "git"
set :branch,       "master"

set :use_sudo,     false
set :user,         "daitss"
set :group,        "daitss" 

set :bundle_without,      []
set :keep_releases, 4   # default is 5

def usage(*messages)
  STDERR.puts "Usage: cap deploy -S target=<host:filesystem>"  
  STDERR.puts messages.join("\n")
  STDERR.puts "You may set the remote user and group by using -S who=<user:group>. Defaults to #{user}:#{group}."
  STDERR.puts "If you set the user, you must be able to ssh to the target host as that user."
  STDERR.puts "You may set the branch in a similar manner: -S branch=<branch name> (defaults to #{variables[:branch]})."
  exit
end

usage('The deployment target was not set (e.g., target=ripple.fcla.edu:/opt/web-services/sites/describe).') unless (variables[:target] and variables[:target] =~ %r{.*:.*})

_domain, _filesystem = variables[:target].split(':', 2)

set :deploy_to,  _filesystem
set :domain,     _domain

set :default_environment, { 
  'PATH' => "/opt/ruby-1.9.3-p545/bin:$PATH",
  'RUBY_VERSION' => 'ruby 1.9.3-p545'
}

if (variables[:who] and variables[:who] =~ %r{.*:.*})
  _user, _group = variables[:who].split(':', 2)
  set :user,  _user
  set :group, _group
end

role :app, domain

# after "deploy:update", "deploy:layout", "deploy:doc", "deploy:restart"

after "deploy:update", "deploy:layout"

namespace :deploy do
  
  desc "Create the directory hierarchy, as necessary, on the target host"
  task :layout, :roles => :app do
    # make everything group ownership daitss, for easy maintenance.
    # run "find #{shared_path} #{release_path} -print0 | xargs -0 chgrp #{group}"
  end
  
end
