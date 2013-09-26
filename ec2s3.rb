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
  dir = config["#{keyword}"]

  AWS.config(
    :access_key_id => config["aws_access_key"],
    :secret_access_key => config["aws_secret_access_key"],
    :s3_endpoint => config["region"]
  )
  s3 = AWS::S3.new
  Dir.chdir("tweets/#{keyword}/tweet")

  # 現在cronで追記を行っているファイルを格納対象から除外
  # fileは現在追記を行っているファイル名
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
    min = 00
  elsif day.min >= 30
    min = 30
  end

  updatingfile = "#{day.year}-#{month}-#{date}-#{hour}-#{min}_#{wdays[day.wday]}_#{dir}.csv"
  puts "#{updatingfile} 以外をアップロード"

   # filenameはディレクトリ内のすべてのcsvファイル名
   # updatingfileとfilenameが一致しなければgz圧縮して元ファイルを削除
  filename = "filename"
  Dir.glob("*.csv").each {|all_csv_file|
    filename = all_csv_file
    if File.basename(filename) != updatingfile
      csvtext = nil
      gzfile = "#{File.basename(all_csv_file)}.gz"
      File.open(all_csv_file,'a+') {|f|
        csvtext = f.read
      }
      Zlib::GzipWriter.open("#{all_csv_file}.gz") {|gz|
        gz.write csvtext
      }
      p "delete! #{filename} ------------------"
      File.delete(filename)
    else
      p "keep! #{File.basename(filename)}^^^^^^^^^^^^^^^^^^^"
    end
    # 作成したgzを、ファイル名に基づいてs3内に作成したデレクトリに格納し、元ファイルを後削除
    if gzfile
      bucket = s3.buckets["dsb-twitter-test/tweets/#{dir}/#{File.basename(filename)[0..3]}/#{File.basename(filename)[5..6]}/#{File.basename(filename)[8..9]}"]
      puts "/#{dir}/#{File.basename(filename)[0..3]}/#{File.basename(filename)[5..6]}/#{File.basename(filename)[8..9]}/#{gzfile}"
      filename = File.basename(gzfile)
      o = bucket.objects[filename]
      o.write(:file => filename)
      File.delete(gzfile)
    end
  }
end


ec2s3(ARGV[0])
