# coding: utf-8
require 'bundler/setup'
Bundler.setup
Bundler.require
require 'yaml'
require 'fileutils'

config = YAML.load_file('./config.yaml')
day = Time.now
  #keyの引数を指定
Twitter.configure do |cnf|
  cnf.consumer_key = config["consumer_key#{ARGV[0].to_i}"]
  cnf.consumer_secret = config["consumer_secret#{ARGV[0].to_i}"]
  cnf.oauth_token = config["oauth_token#{ARGV[0].to_i}"]
  cnf.oauth_token_secret = config["oauth_token_secret#{ARGV[0].to_i}"]
end

keyword = config["#{ARGV[1]}"]
since_id = 0    # 前回実行時に最後に取得したtweetのid
first_tw_id = 0  
last_tw_id = 0 
first_date = 0  
last_date = 0  
tw_sum = 0  
limit = 0  
arr_main = []  
arr_check =[]  
arr_error = []  
main_num = 0  
error_num = 0  
num = 0  
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


if config["#{ARGV[1]}"]
    # 初回実行時はディレクトリを作成 since_idは前回取得した中で最も新しいtweetのid 前回実行時の最新tweet_idを取得、なければid = 0
  FileUtils::mkdir_p("tweets/error") unless FileTest.exist?("tweets/error")
  FileUtils::mkdir_p("tweets/#{ARGV[1]}/check/") unless FileTest.exist?("tweets/#{ARGV[1]}/check/")
  FileUtils::mkdir_p("tweets/#{ARGV[1]}/tweet/") unless FileTest.exist?("tweets/#{ARGV[1]}/tweet/")
  Dir.chdir("tweets/#{ARGV[1]}")

  sleep(ARGV[0].to_i * 2)

  File.open("check/id_#{keyword}.txt",'a+') {|f|
    since_id = f.readlines[-1]
    since_id = since_id.to_i
  }
  File.open("check/id_#{keyword}.txt",'w'){|check|
    check.write since_id
  }


    # ARGV[1]に検索語句 引数で受け取ったワードを元に、検索結果を取得し、古いものから順に並び替え since_id以降のtweetから時系列順に100件を取得
  until limit == 5 do
    until_num = 0
    begin
      Twitter.search(ARGV[1], :count => 100, :result_type => "recent", :since_id => since_id, :lang=>"ja").results.reverse.each do |status|
        text = status.text.gsub(/(\r\n|\r|\n)/," ")
        text = text.gsub(",","、")
        text = text.gsub("\"","”")

       if status.retweeted_status
        rtext = status.retweeted_status.text.gsub(/(\r\n|\r|\n)/," ")
        rtext = rtext.gsub(",","、")
        rtext = rtext.gsub("\"","”")
      end
      
       if !status.place && !status.retweeted_status
        arr_main[main_num] =  "#{status.created_at},#{text},#{status.id},#{status.user.screen_name},#{status.user.friends_count},#{status.user.followers_count},#{status.retweet_count},#{status.user.id}\n"
       elsif !status.place && status.retweeted_status
        arr_main[main_num] = "#{status.created_at},RT #{rtext},#{status.id},#{status.user.screen_name},#{status.user.friends_count},#{status.user.followers_count},#{status.retweet_count},#{status.user.id}\n"
       elsif status.place && !status.retweeted_status
        arr_main[main_num] =  "#{status.created_at},#{text},#{status.id},#{status.user.screen_name},#{status.user.friends_count},#{status.user.followers_count},#{status.retweet_count},#{status.user.id},#{status.place.full_name}\n"
       else
        arr_main[main_num] =  "#{status.created_at},RT #{rtext},#{status.id},#{status.user.screen_name},#{status.user.friends_count},#{status.user.followers_count},#{status.retweet_count},#{status.user.id},#{status.place.full_name}\n"
       end

        if until_num == 0
          first_date = status.created_at
          first_tw_id = status.id
          last_date = status.created_at
          last_tw_id = status.id
        else
          last_date = status.created_at
          last_tw_id = status.id
        end

        tw_sum += 1
        until_num += 1
        main_num += 1
      end
      since_id = last_tw_id
      sleep(2)
    rescue Twitter::Error::ClientError => e
      arr_error[error_num] = "\n実行日時 #{day}   エラー発生日時 #{Time.now}\nerror : #{e}\n"
      error_num += 1
      retry
    end
    if until_num != 0
       arr_check[limit] = "\n#{last_tw_id}"
    else
      break
    end
    limit += 1
  end

  until num >= main_num && num>= error_num
    if num <= main_num && day.min < 30
      File.open("tweet/#{day.year}-#{month}-#{date}-#{hour}-00_#{wdays[day.wday]}_#{keyword}.csv",'a'){|main|
        main.write arr_main[num]
      }
    elsif num <= main_num && day.min >= 30
      File.open("tweet/#{day.year}-#{month}-#{date}-#{hour}-30_#{wdays[day.wday]}_#{keyword}.csv",'a'){|main|
        main.write arr_main[num]
      }
    end
    if num <= error_num && error_num != 0
      File.open("../error/#{day.year}-#{month}-#{date}-#{hour}_#{wdays[day.wday]}_#{keyword}_error.txt",'a'){|error|
        error.write arr_error[num]
      }
     end
    num += 1
  end
  File.open("check/id_#{keyword}.txt",'a'){|check|
    check.write arr_check[-1]
  }
else
  puts "Please check #{ARGV[1]} in config.yaml"
end