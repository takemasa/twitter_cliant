require 'tweetstream'
require 'yaml'

config = YAML.load_file('./config.yaml')
require 'em-twitter'
require 'json'
 
option = { 
  :path => "/1/statuses/filter.json",
  :params => {:track => "Ruby"},
  :oauth => {
   :consumer_key => config['consumer_key'],
   :consumer_secret => config['consumer_secret'],
   :token => config['oauth_token'],
   :token_secret => config['oauth_token_secret']
  }
}
 
EM.run do
  client = EM::Twitter::Client.connect(option)
 
  client.each do |result|
    tweets = JSON::parse(result)
    puts tweets["text"]
  end 
end