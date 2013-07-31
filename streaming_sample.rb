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
#  有線の場合
#  cnf.proxy = { :uri => 'http://proxy.val.co.jp:8080' }
end

TweetStream::Client.new.sample do |status|
  text = status.text.gsub(/(\r\n|\r|\n)/," ")
  text = text.gsub(",","，")
  puts "#{status.created_at},#{status.lang},#{text}"
end