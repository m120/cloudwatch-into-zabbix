#!/usr/bin/env ruby
## -------------------------------------------------------------
#
# CloudWatch Data Getter 
# 		For Zabbix Ver2.0 later
# 		- Write by mhori 141125
#
# >> Reference << 
#    Base:
#        http://dev.classmethod.jp/cloud/aws/zabbix-with-cloudwatch/
#        http://www.xmisao.com/2014/07/29/ruby-aws-sdk-get-cloudwatch-metrics.html
#    Metrcs Reference:
#        http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/CW_Support_For_AWS.html
#
# >> Install <<
#  1. ruby package install
#      $ sudo yum install rubygems rubygem-aws-sdk.noarch
#
#  2. this script copy to /etc/zabbix/externalscripts/
#      $ ls -l zabbixsrv:zabbixsrv /etc/zabbix/externalscripts/CloudWatch.rb
# 
# >> Example << 
# (Terminal)
#  ruby ./CloudWatch.rb {$ACCESS_KEY} {$SECRET_ACCESS_KEY} ap-northeast-1 RDS CPUUtilization DBInstanceIdentifier {$DB_II} Average
#
# >> Zabbix settings <<
#  1. Setting Host Macro
# 	{$ACCESS_KEY}: AWS Access Key
#  	{$SECRET_ACCESS_KEY}: AWS Secret Access Key 
#  	{$DB_II}: AWS RDS DBInstanceIdentifier
#  2. Item Key:
#	CloudWatch.rb["{$ACCESS_KEY}", "{$SECRET_ACCESS_KEY}", "ap-northeast-1", "RDS", "CPUUtilization", "DBInstanceIdentifier", "{$DB_II}", "Average"]
#
## ------------------------------------------------------------
 
require 'rubygems'
require 'aws-sdk'
require 'optparse'

$access_key=ARGV[0]
$secret_access_key=ARGV[1]
$region=ARGV[2]
$service=ARGV[3]
$metric=ARGV[4]
$dimension_name=ARGV[5]
$dimension_value=ARGV[6]
$statistics=ARGV[7]

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
