require 'tweetstream'
require 'yaml'

config = YAML.load_file('./config.yaml')

TweetStream.configure do |cnf|
  cnf.consumer_key = config['consumer_key']
  cnf.consumer_secret = config['consumer_secret']
  cnf.oauth_token = config['oauth_token']
  cnf.oauth_token_secret = config['oauth_token_secret']
  cnf.auth_method            = :oauth
end
client = TweetStream::Client.new

client.on_error do |message|
  puts message
end

client.on_direct_message do |direct_message|
  puts direct_message.text
end

client.on_timeline_status  do |status|
  puts status.text
end

client.userstream