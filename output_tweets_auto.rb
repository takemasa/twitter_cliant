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

since_id = 0
first_tw_id = 0
last_tw_id = 0
first_date = 0
last_date = 0
tw_num = 0
limit = 0
k = 10
  # 初回実行時はディレクトリを作成 since_idは前回取得した中で最も新しいtweetのid 前回実行時の最新tweet_idを取得、なければid = 0
FileUtils::mkdir_p("../tweets/output/#{ARGV[0]}/check/") unless FileTest.exist?("../tweets/output/#{ARGV[0]}/check/")

File.open("../tweets/output/#{ARGV[0]}/check/#{ARGV[0]}_#{day.year}-#{day.month}-#{day.day}-#{day.hour}_id.txt",'a+') {|f|
  since_id = f.readlines[-1]
  since_id = since_id.to_i
}

#ARGV[1]に検索語句 引数で受け取ったワードを元に、検索結果を取得し、古いものから順に並び替え since_id以降のtweetから時系列順に100件を取得
until k <= 5 || limit == -1 do
  until_num = 0
  begin
    Twitter.search(ARGV[0], :count => 100, :result_type => "recent", :since_id => since_id, :lang=>"ja").results.reverse.each do |status|
      text = status.text.gsub(/(\r\n|\r|\n)/," ")
      text = text.gsub(","," ")
      File.open("../tweets/output/#{ARGV[0]}/#{ARGV[0]}_#{day.year}-#{day.month}-#{day.day}-#{day.hour}.csv",'a'){|f|
        f.write "#{status.created_at},#{text},#{status.user.screen_name},#{status.user.id},#{status.id},#{status.place},\n" 
      }

      if tw_num == 0
        first_date = status.created_at
        first_tw_id = status.id
      else
        last_date = status.created_at
        last_tw_id = status.id
      end

      tw_num += 1
      until_num += 1
    end

    limit += 1 
    since_id = last_tw_id
    k = until_num
    sleep(5)

  rescue Twitter::Error::ClientError => e
    File.open("../tweets/output/#{ARGV[0]}/check/#{ARGV[0]}_#{day.year}-#{day.month}-#{day.day}-#{day.hour}_error.txt",'a'){|f|
      f.write "\n実行日時 #{day}\nerror : #{e}\n" 
    }
    retry
  end

  if limit ==  1 && until_num != 1
    File.open("../tweets/output/#{ARGV[0]}/check/#{ARGV[0]}_#{day.year}-#{day.month}-#{day.day}-#{day.hour}_id.txt",'a'){|f|
      f.write "\n\n実行日時 #{day}\nFirst Tweet: #{first_date}\n#{first_tw_id}\nget_sum: #{until_num}\ntotal_sum #{tw_num}\nLatest Tweet: #{last_date}\n#{last_tw_id}" 
    }
  elsif until_num >= 2
    File.open("../tweets/output/#{ARGV[0]}/check/#{ARGV[0]}_#{day.year}-#{day.month}-#{day.day}-#{day.hour}_id.txt",'a'){|f|
      f.write "\n\nFirst Tweet: #{first_date}\n#{first_tw_id}\nget_sum: #{until_num}\ntotal_sum #{tw_num}\nLatest Tweet: #{last_date}\n#{last_tw_id}" 
    }
  elsif until_num <= 1
    File.open("../tweets/output/#{ARGV[0]}/check/#{ARGV[0]}_#{day.year}-#{day.month}-#{day.day}-#{day.hour}_id.txt",'a'){|f|
     f.write "\n\nFirst Tweet: #{first_date}\n#{first_tw_id}\nget_sum: #{until_num}\ntotal_sum #{tw_num}\nLatest Tweet: #{first_date}\n#{first_tw_id}" 
    }
  end
end