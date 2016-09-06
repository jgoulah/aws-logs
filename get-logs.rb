#!/usr/bin/env ruby

# run these commands:
# brew install pip
# pip install awscli
# mkdir logs

require "json"
require 'optparse'

# parse options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"

  opts.on("-d", "--database DATABASE", "Database to run against") do |v|
    options[:database] = v
  end
end.parse!

# set db option or fail
raise OptionParser::MissingArgument.new("option 'database' is missing") if options[:database].nil?
database = options[:database]

# look for all logs for that db, and download each
rawlogs = %x{aws rds describe-db-log-files --db-instance-identifier #{database}}
logs = JSON.parse(rawlogs)
logs['DescribeDBLogFiles'].each do |log|
  logname = log['LogFileName']
  savepath = File.basename(logname)
  puts "log name is #{logname} and saving at #{savepath}"
  %x{aws rds download-db-log-file-portion  --db-instance-identifier=#{database} --starting-token=0 --log-file-name=#{logname} > logs/#{savepath}}
end
