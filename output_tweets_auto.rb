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
  cnf.consumer_key = config["consumer_key#{ARGV[1].to_i}"]
  cnf.consumer_secret = config["consumer_secret#{ARGV[1].to_i}"]
  cnf.oauth_token = config["oauth_token#{ARGV[1].to_i}"]
  cnf.oauth_token_secret = config["oauth_token_secret#{ARGV[1].to_i}"]
end

since_id = 0    # 前回実行時に最後に取得したtweetのid
first_tw_id = 0  #
last_tw_id = 0  #
first_date = 0  #
last_date = 0  #
tw_sum = 0  #
limit = 0  #
arr_main = []  #
arr_check =[]  #
arr_error = []  #
main_num = 0  #
error_num = 0  #
num = 0  #

  # 初回実行時はディレクトリを作成 since_idは前回取得した中で最も新しいtweetのid 前回実行時の最新tweet_idを取得、なければid = 0
FileUtils::mkdir_p("../tweets/output/#{ARGV[0]}/log") unless FileTest.exist?("../tweets/output/#{ARGV[0]}/log")
FileUtils::mkdir_p("../tweets/output/#{ARGV[0]}/check/") unless FileTest.exist?("../tweets/output/#{ARGV[0]}/check/")

File.open("../tweets/output/#{ARGV[0]}/check/#{ARGV[0]}_id.txt",'a+') {|f|
  since_id = f.readlines[-1]
  since_id = since_id.to_i
}

sleep(ARGV[1].to_i * 3)
  # ARGV[0]に検索語句 引数で受け取ったワードを元に、検索結果を取得し、古いものから順に並び替え since_id以降のtweetから時系列順に100件を取得
until limit == 7 do
  until_num = 0
  begin
    Twitter.search(ARGV[0], :count => 100, :result_type => "recent", :since_id => since_id, :lang=>"ja").results.reverse.each do |status|
      text = status.text.gsub(/(\r\n|\r|\n)/," ")
      text = text.gsub(","," ")

      if status.place  # 出力は左から生成日、本文、ツイートid、ユーザ名、フォロー数、フォロワー数、ユーザid、現在地
        arr_main[main_num] =  "#{status.created_at},#{text},#{status.id},#{status.user.screen_name},#{status.user.friends_count},#{status.user.followers_count},#{status.retweet_count},#{status.user.id},#{status.place.full_name}\n"
      else
        arr_main[main_num] =  "#{status.created_at},#{text},#{status.id},#{status.user.screen_name},#{status.user.friends_count},#{status.user.followers_count},#{status.retweet_count},#{status.user.id}\n"
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
    arr_error[error_num] = "\n実行日時 #{day}\nerror : #{e}\n"
    error_num += 1 
    retry
  end

  # 取得したツイートのおおよその量をARGV[0]_id.txtで可視化
  if until_num > 90 && limit != 0
    until_num = "************************************************************#{until_num}********************************************************************burst!?"
  elsif until_num > 50 && limit != 0
    until_num = "************************************************************#{until_num}*************************burst?"
  end

  if limit ==  0 && until_num != 0
    arr_check[limit] = "\n\n***************************************\n実行日時 #{day}\nFirst Tweet: #{first_date}\n#{first_tw_id}\ntotal_sum #{tw_sum}\nget_sum: #{until_num}\nLatest Tweet: #{last_date}\n#{last_tw_id}" 
  elsif limit != 0 && until_num >= 1
    arr_check[limit] =  "\n\nFirst Tweet: #{first_date}　id: #{first_tw_id}\ntotal_sum: #{tw_sum}  get_sum: #{until_num}\nLatest Tweet: #{last_date}\n#{last_tw_id}" 
  else
    break
  end
  limit += 1 
end

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


until num >= main_num && num >= limit && num>= error_num
  if num <= main_num && day.min < 30
    File.open("../tweets/output/#{ARGV[0]}/#{ARGV[0]}_#{day.year}-#{month}-#{date}-#{hour}-0.csv",'a'){|main|
      main.write arr_main[num]
    }
  elsif num <= main_num && day.min >= 30
    File.open("../tweets/output/#{ARGV[0]}/#{ARGV[0]}_#{day.year}-#{month}-#{date}-#{hour}-30.csv",'a'){|main|
      main.write arr_main[num]
    }
  end
  if num <= limit
    File.open("../tweets/output/#{ARGV[0]}/check/#{ARGV[0]}_id.txt",'a'){|check|
      check.write arr_check[num]
    }
  end
  if num <= error_num && error_num != 0
    File.open("../tweets/output/#{ARGV[0]}/check/#{ARGV[0]}_#{day.year}-#{month}-#{date}-#{hour}_error.txt",'a'){|error|
      error.write arr_error[num] 
    }
  end
  num += 1
end

