# coding: utf-8
require 'bundler/setup'
Bundler.setup
Bundler.require
require 'yaml'

config = YAML.load_file('./config.yaml')

TweetStream.configure do |cnf|
  cnf.consumer_key = config['consumer_key']
  cnf.consumer_secret = config['consumer_secret']
  cnf.oauth_token = config['oauth_token']
  cnf.oauth_token_secret = config['oauth_token_secret']
  cnf.auth_method = :oauth
end

client = TweetStream::Client.new
puts client
client.on_error do |message|
  p message
end
client.track("おこ") do |status|
  puts "1"
end
