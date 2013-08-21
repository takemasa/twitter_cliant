# coding: utf-8
require 'bundler/setup'
Bundler.setup
Bundler.require
require 'yaml'
require 'fileutils'

config = YAML.load_file('./config.yaml')

AWS.config(
  :access_key_id => config["aws_access_key"],
  :secret_access_key => config["aws_secret_access_key"],
  :s3_endpoint => config["region"]
)
s3 = AWS::S3.new

bucket = s3.buckets["dsb-twitter-test/tweets/#{ARGV[1]}"]
dir = Dir.glob("/home/ec2-user/twitter/tweets/#{ARGV[0]}/tweet/*.csv").each {|all_csv_file|
	p all_csv_file
	filename = all_csv_file
	basename = File.basename(filename)
	o = bucket.objects[basename]
	o.write(:file => filename)
	File.delete(all_csv_file)
}
bucket = s3.buckets["dsb-twitter-test/tweets/check"]
dir = Dir.glob("/home/ec2-user/twitter/tweets/#{ARGV[0]}/check/*.txt").each {|all_txt_file|
	p all_txt_file
	filename = all_txt_file
	basename = File.basename(filename)
	o = bucket.objects[basename]
	o.write(:file => filename)
	if !(/_id/ =~ all_txt_file)
		File.delete(all_txt_file)
	end
}