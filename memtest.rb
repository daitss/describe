#!/usr/local/env ruby
require 'rubygems' 

# d1 dedup report
pid = ARGV.shift or raise "pid required"


`curl http://localhost:7002/describe?location=file:///Users/Carol/tools/jhove/invalidMIX.tif`
`curl http://localhost:7002/debug`
puts `vmmap #{pid}`
d = Dir.glob("/Users/Carol/testpackage/UF00053733_00004/*")
d.each  do |file| 
  puts "describe #{file}"
  `curl http://localhost:7002/describe?location=file://#{file}`
end

`curl http://localhost:7002/debug`
puts `vmmap #{pid}`