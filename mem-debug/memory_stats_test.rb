require 'memory_debug'

memory_stats # => shows table of memory usage
delta_stats # => shows new memory usage since last call of delta_stats (none)

strings = []
100000.times do |i|
  strings << i.to_s
end

delta_stats # => will show creation of ~100000 new strings

objects = []
100000.times do |i|
  objects << Object.new
end

delta_stats # => will show creation of 100000 new objects
