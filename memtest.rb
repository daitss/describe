#!/usr/local/env ruby
require 'rubygems'

# process id and data directory
pid = ARGV.shift or raise "pid required"
datadir = ARGV.shift or raise "data directory required"

current_dir =Dir.getwd 
`curl http://localhost:3000/describe?location=file://#{current_dir}/files/tjpeg.tif`
`curl http://localhost:3000/debug`
#puts `vmmap #{pid}`
puts `ps u -p #{pid}`
puts `cat /proc/#{pid}/status`
puts `cat /proc/#{pid}/smaps`

d = Dir.glob("#{datadir}*")
d.each  do |file|
  `curl -s http://localhost:3000/describe?location=file://#{file}`
end

`curl http://localhost:3000/debug`
#puts `vmmap #{pid}`
puts `ps u -p #{pid}`
puts `cat /proc/#{pid}/status`
puts `cat /proc/#{pid}/smaps`
