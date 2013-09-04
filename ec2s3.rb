# coding: utf-8
require 'bundler/setup'
Bundler.setup
Bundler.require
require 'yaml'
require 'fileutils'

# 第1引数は検索語句
def ec2s3(keyword)
  day = Time.now
  wdays = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
  config = YAML.load_file('./config.yaml')
  dir_name = config[keyword]

  AWS.config(
    :access_key_id => config["aws_access_key"],
    :secret_access_key => config["aws_secret_access_key"],
    :s3_endpoint => config["region"]
  )
  s3 = AWS::S3.new
  Dir.chdir("tweets/#{keyword}/tweet")
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

  # 現在収集中のツイートを書き込んでいるファイル名
  if day.min < 30
    file = "#{day.year}-#{month}-#{date}-#{hour}-0_#{wdays[day.wday]}_#{dir_name}.csv"
  elsif day.min >= 30
    file = "#{day.year}-#{month}-#{date}-#{hour}-30_#{wdays[day.wday]}_#{dir_name}.csv"
  end
  # puts "#{file} 以外をアップロード"
  files = files
  dir = Dir.glob("*.csv").each {|all_csv_file|
    files = "#{all_csv_file}"
    # p files
    if File.basename(files) != file
        zipfile = "#{File.basename(all_csv_file)}.zip"
        Zip::Archive.open(zipfile, Zip::CREATE) do |arc|
          arc.add_file(files)
        end
        # p "delete! #{files} ------------------"
        File.delete(files)
    elsif File.basename(files) == file
      # p "keep! #{File.basename(files)}"
      # p "keep! #{file}^^^^^^^^^^^^^^^^^^^"
    end
    dir = config["#{keyword}"]
    if zipfile
      bucket = s3.buckets["dsb-twitter-test/tweets/#{dir}/#{File.basename(files)[0..3]}/#{File.basename(files)[5..6]}/#{File.basename(files)[8..9]}"]
      # p zipfile
      # puts "dsb-twitter-test/tweets/#{config["#{keyword}"]}/#{File.basename(files)[0..3]}/#{File.basename(files)[5..6]}/#{File.basename(files)[8..9]}に格納します"
      filename = File.basename(zipfile)
      o = bucket.objects[filename]
      o.write(:file => filename)
      File.delete(zipfile)
    end
  }
end


ec2s3(ARGV[0])