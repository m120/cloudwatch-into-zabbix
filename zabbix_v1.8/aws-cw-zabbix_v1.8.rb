#!/usr/bin/ruby

require 'rubygems'
require 'aws-sdk'
require 'optparse'

$hostname=ARGV[0]
$access_key=ARGV[1]
$secret_access_key=ARGV[2]
$region=ARGV[3]
$service=ARGV[4]
$metric=ARGV[5]
$dimension_name=ARGV[6]
$dimension_value=ARGV[7]
$statistics=ARGV[8]

AWS.config({
  :access_key_id => "#{$access_key}",  
  :secret_access_key => "#{$secret_access_key}",
  :cloud_watch_endpoint => "monitoring.""#{$region}"".amazonaws.com"
})

metric = AWS::CloudWatch::Metric.new("AWS/""#{$service}", "#{$metric}")
 
stats = metric.statistics(
  :start_time => Time.now - 300,
  :end_time => Time.now,
  :statistics => "#{$statistics}",
  :dimensions => [{:name => "#{$dimension_name}",:value => "#{$dimension_value}"}]
)

last_stats = stats.sort_by{|stat| stat[:timestamp]}.last
 
exit if last_stats.nil?

puts last_stats["#{$statistics}".downcase.to_sym]
