# coding: utf-8
require 'twitter'
require 'yaml'

config = YAML.load_file('./config.yaml')

Twitter.configure do |cnf|
  cnf.consumer_key = config['consumer_key']
  cnf.consumer_secret = config['consumer_secret']
  cnf.oauth_token = config['oauth_token']
  cnf.oauth_token_secret = config['oauth_token_secret']
end

since_id = 0
counter = 0

# 無限ループ
#ARGV[0]に検索語句、ARGV[1]に検索の間隔(s)
while counter == 0  do 
  begin
      # 引数で受け取ったワードを元に、検索結果を取得し、古いものから順に並び替え
      # ※最初はsince_id=0であるため、tweet ID 0以降のTweetから最新のもの上位100件を取得
      #一度に取得できる限界数は100
      Twitter.search(ARGV[0], :count => 30000, :result_type => "recent", :since_id => since_id).results.reverse.map do |status|

        # Tweet ID, ユーザ名、Tweet本文、投稿日を1件づつ表示
        "#{status.id} :#{status.from_user}: #{status.text} : #{status.created_at} "

        # p status.id
        # p "@" + status.from_user
        puts status.text
        p status.created_at
        text = status.text.gsub(/(\r\n|\r|\n)/," ")
        text = text.gsub(","," ")
        File.open("#{ARGV[0]}.csv",'a'){|f|
        f.write "#{text},#{status.created_at}\n" #@#{status.from_user}
        }
        # 取得したTweet idをsince_idに格納
        # ※古いものから新しい順(Tweet IDの昇順)に表示されるため、
        #  最終的に、取得した結果の内の最新のTweet IDが格納され、
        #  次はこのID以降のTweetが取得される
        since_id=status.id
      end
      # 5秒に一回が限界速度
      sleep(5)
      # 検索ワードで Tweet を取得できなかった場合の例外処理
      rescue Twitter::Error::ClientError
        sleep(1)
      retry
  end
end