# coding: utf-8
require 'bundler/setup'
Bundler.setup
Bundler.require
require 'yaml'
require 'fileutils'

config = YAML.load_file('./config.yaml')
day = Time.now

(account_num, search_keyword) = ARGV

  #keyの引数を指定
Twitter.configure do |cnf|
  cnf.consumer_key = config["consumer_key#{account_num.to_i}"]
  cnf.consumer_secret = config["consumer_secret#{account_num.to_i}"]
  cnf.oauth_token = config["oauth_token#{account_num.to_i}"]
  cnf.oauth_token_secret = config["oauth_token_secret#{account_num.to_i}"]
end


keyword = config[search_keyword]
since_id = 0    # 前回実行時に最後に取得したtweetのid
first_tw_id = 0  
last_tw_id = 0 
first_date = 0  
last_date = 0  
limit = 0  
arr_main = []  
arr_check =[]  
arr_error = []  
main_num = 0  
error_num = 0  
wdays = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]



if day.month < 10
  month = "0#{day.month}"
else
  month = day.month
end
if day.day < 10
  date = "0#{day.day}"
else
  date = day.day
end
if day.hour < 10
  hour = "0#{day.hour}"
else
  hour = day.hour
end
if day.min < 30
  half = "00"
else
  half = "30"
end

if config[search_keyword]
    # 初回実行時はディレクトリを作成 since_idは前回取得した中で最も新しいtweetのid 前回実行時の最新tweet_idを取得、なければid = 0
  FileUtils::mkdir_p("tweets/error") unless FileTest.exist?("tweets/error")
  FileUtils::mkdir_p("tweets/#{search_keyword}/check/") unless FileTest.exist?("tweets/#{search_keyword}/check/")
  FileUtils::mkdir_p("tweets/#{search_keyword}/tweet/") unless FileTest.exist?("tweets/#{search_keyword}/tweet/")
  Dir.chdir("tweets/#{search_keyword}")

  sleep(account_num.to_i % 10 * 2)

  File.open("check/id_#{keyword}.txt",'a+') {|f|
    since_id = f.readlines[-1]
    since_id = since_id.to_i
  }
  File.open("check/id_#{keyword}.txt",'w')


    # search_keywordに検索語句 引数で受け取ったワードを元に、検索結果を取得し、古いものから順に並び替え since_id以降のtweetから時系列順に100件を取得
  until limit == 2 do
    until_num = 0
    begin
      Twitter.search(search_keyword, :count => 100, :result_type => "recent", :since_id => since_id, :lang=>"ja").results.reverse.each do |status|
        # テキストのクリーニング
        if status.retweeted_status.nil?
          text = status.text
        else
          text = "RT #{status.retweeted_status.text}"
        end
        text = text.gsub(/(\r\n|\r|\n)/," ")
        text = text.gsub(",","、")
        text = text.gsub("\"","”")


        # レコードの項目
        record_ary = [
          status.created_at,
          text,
          status.id,
          status.user.screen_name,
          status.user.friends_count,
          status.user.followers_count,
          status.retweet_count,
          status.user.id
        ]
        # 位置情報が存在する場合は追加
        record_ary << status.place.full_name if status.place           

        arr_main[main_num] = record_ary.join(",")
      
        if until_num == 0
          first_date = status.created_at
          first_tw_id = status.id
        end
        last_date = status.created_at
        last_tw_id = status.id

        until_num += 1
        main_num += 1
      end
      since_id = last_tw_id
      sleep(10)
    rescue Twitter::Error::TooManyRequests
      break
    rescue Twitter::Error::ServiceUnavailable
      break
    rescue Twitter::Error::ClientError => e
      arr_error[error_num] = ["execute_time:#{day}", "error_time:#{Time.now}", "message:#{e}"].join("\t")
      error_num += 1
      sleep 1

      retry
    end

    arr_check[limit] = last_tw_id
    limit += 1
  end

  File.open("check/id_#{keyword}.txt",'a'){|check|
    check.puts arr_check
  }

  if main_num != 0
    File.open("tweet/#{day.year}-#{month}-#{date}-#{hour}-#{half}_#{wdays[day.wday]}_#{keyword}.csv",'a'){|main|
      main.puts arr_main
    }
  end

  if error_num != 0
    File.open("../error/#{day.year}-#{month}-#{date}-#{hour}_#{wdays[day.wday]}_#{keyword}_error.txt",'a+'){|error|
      error.puts arr_error
    }
  end
  
else
  puts "Please check #{search_keyword} in config.yaml"
end
