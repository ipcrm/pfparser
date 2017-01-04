#!/usr/bin/env ruby

require 'trollop'

mods = {}
needsparse = []

# Get Args
opts = Trollop::options do
  opt :filename, "File to process", :type => String
  opt :module, "Module to modify", :type => String
  opt :param, "Param to change", :type => String
  opt :data, "Data for param to change", :type => String
end

Trollop::die :filename, "must be supplied" unless not opts[:filename].nil?
Trollop::die :module, "must be supplied" unless not opts[:module].nil?
Trollop::die :param, "must be supplied" unless not opts[:param].nil?
Trollop::die :data, "must be supplied" unless not opts[:data].nil?

# Find the forge modules, jam them in a hash and move on
File.readlines(opts[:filename]).each do |line|
  if match = line.match(/^\s?+mod\s+?[',"](\w+[\/,-]\w+)[',"],[\s]+[',"](\d+.\d+.\d+)[',"]\s?+$/)
    mod,ver = match.captures
    mods[mod] = {}
    mods[mod]['type'] = 'forge'
    mods[mod]['version'] = ver
  else
    needsparse << line
  end
end

moreparse = []
needsparse.each_with_index do |d,i|
  if match = d.match(/^\s?+mod\s+?[',"]([A-z-]+)[',"]\s?+,\s?+$/)
    mod = match.captures[0]

    mods[mod] = {}
    mods[mod]['type'] = 'vcs'

    # We found a module, now lets do some nesting looping ... ugh
    # We are looking for all lines following this that start with a :<word> because those will be
    # directives we need
    needsparse.each_with_index do |nd,ni|
      if not ni > i
        next
      end

      if match = nd.match(/^\s+(:\w+)[\s+]?=>\s+?[',"]?([A-z\-\@\.\:\/0-9]+)[',"]?[\s+]?[,]?[\s+]?$/)
        param,data = match.captures
        mods[mod][param] = data
      end

      nd.match(/^$/) && break
      nd.match(/^\s?+mod\s+?[',"]([A-z-]+)[',"]\s?+,\s?+$/) && break
    end

  else
    if not d.match(/^\s+(:\w+)[\s+]?=>\s+?[',"]?([A-z\-\@\.\:\/0-9]+)[',"]?[\s+]?[,]?[\s+]?$/) and not d.match(/^#/) and not d.match(/^$/)
      moreparse << d
    end
  end
end

# Update module data
if mods.keys.include?(opts[:module])
  if mods[ opts[:module] ].keys.include?( opts[:param] )
    mods[ opts[:module] ][ opts[:param] ] = opts[:data]
  else
    puts "No parameter '#{opts[:param]}' found for module #{opts[:module]} in Puppetfile!\nAvailable params #{mods[ opts[:module] ].keys - ['type']}"
    exit 1
  end
else
  puts "Cannot find module #{opts[:module]} in Puppetfile!"
  exit 2
end

# Create new puppetfile
newpf=""
newpf << moreparse.join("\n")

mods.keys.each do |m|
  if mods[m]['type'] == 'forge'
    newpf << "mod '#{m}',    '#{mods[m]['version']}'\n"
  elsif mods[m]['type'] == 'vcs'
    newpf << "\nmod '#{m}',\n"
    k_l = ( mods[m].keys.length - 1 )
    mods[m].keys.each_with_index do |k,ki|
      if k != 'type'
        newpf << "  #{k} => '#{mods[m][k]}'#{"," if ki != k_l}\n"
      end
    end
  end
end

File.open(opts[:filename], "w") do |file|
    file.puts newpf
end
