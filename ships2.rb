# coding: utf-8
require 'bundler/setup'
Bundler.setup
Bundler.require
require 'yaml'

config = YAML.load_file('./config.yaml')

Twitter.configure do |cnf|
  cnf.consumer_key = config['consumer_key']
  cnf.consumer_secret = config['consumer_secret']
  cnf.oauth_token = config['oauth_token']
  cnf.oauth_token_secret = config['oauth_token_secret']
end

# 変数の初期化
since_id = 0

# 無限ループ
loop do
  begin
    # 引数で受け取ったワードを元に、検索結果を取得し、古いものから順に並び替え
    # ※最初はsince_id=0であるため、tweet ID 0以降のTweetから最新のもの上位100件を取得
    #一度に取得できる限界数は100
    Twitter.search(ARGV[0], :count => 100000000, :result_type => "recent", :since_id => since_id).results.reverse.map do |status|

      # Tweet ID, ユーザ名、Tweet本文、投稿日を1件づつ表示
      "#{status.id} :#{status.from_user}: #{status.text} : #{status.created_at} "

      p status.id
      p "@" + status.from_user
      p status.text
      p status.created_at

      print("\n")
      text = status.text.gsub(/\r\n|\r|\n/," ")
      File.open("#{ARGV[0]}.txt",'a'){|f|
        f.write "#{text},#{status.created_at}\n"
      }
      # 取得したTweet idをsince_idに格納
      # ※古いものから新しい順(Tweet IDの昇順)に表示されるため、
      #  最終的に、取得した結果の内の最新のTweet IDが格納され、
      #  次はこのID以降のTweetが取得される
      since_id=status.id
    end

    # 5秒に一回が限界速度
    sleep(10)

    # 検索ワードで Tweet を取得できなかった場合の例外処理
  rescue Twitter::Error::ClientError
    # 60秒待機し、リトライ
    sleep(5)
    retry
  end
end
