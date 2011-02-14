#!/usr/local/env ruby
require 'rubygems'

# d1 dedup report
pid = ARGV.shift or raise "pid required"

`curl http://localhost:7002/describe?location=file:///Users/franco/code/daitss/describe/files/tjpeg.tif`
`curl http://localhost:7002/debug`
puts `vmmap #{pid}`
puts `ps u -p #{pid}`
d = Dir.glob("/Users/franco/code/daitss/describe/UF00053733_00004/*")
d.each  do |file|
  `curl -s http://localhost:7002/describe?location=file://#{file}`
end

`curl http://localhost:7002/debug`
puts `vmmap #{pid}`
puts `ps u -p #{pid}`
