# coding: utf-8
require 'twitter'
require 'yaml'

config = YAML.load_file('./config.yaml')
day = Time.now

Twitter.configure do |cnf|
  cnf.consumer_key = config['consumer_key']
  cnf.consumer_secret = config['consumer_secret']
  cnf.oauth_token = config['oauth_token']
  cnf.oauth_token_secret = config['oauth_token_secret']
end

since_id = 0
date = day
id = 0

# since_idは前回取得した中で最も新しいtweetのid
# 前回実行時の最新tweet_idを取得、なければid = 0
File.open("../linux/#{ARGV[0]}_id.txt",'a+') {|f|
  if f.readlines[-1] == ""
    since_id = 0
  else
    since_id = f.readlines[-1]
  end
}
  #ARGV[0]に検索語句
  # 引数で受け取ったワードを元に、検索結果を取得し、古いものから順に並び替え
  # since_id以降のtweetから時系列順に100件を取得
  begin
    Twitter.search(ARGV[0], :count => 100, :result_type => "recent", :since_id => since_id).results.reverse.map do |status|

      text = status.text.gsub(/(\r\n|\r|\n)/," ")
      text = text.gsub(","," ")
      File.open("../linux/#{ARGV[0]}.csv",'a'){|f|
      f.write "#{status.created_at},#{text}\n" 
      }
      date = status.created_at
      id = status.id
    end
    # 検索ワードで Tweet を取得できなかった場合の例外処理
    rescue Twitter::Error::ClientError => e
      sleep(10)
      File.open("../linux/#{ARGV[0]}_error.txt",'a'){|f|
    f.write "\n実行日時 #{day}\nerror : #{e}\n" 
  }
    retry
  end
  # 最新tweetのidをテキストファイルに追記
  File.open("../linux/#{ARGV[0]}_id.txt",'a'){|f|
    f.write "\n実行日時 #{day}\nLatest Tweet:\n#{date}\n#{id}\n" 
  }
