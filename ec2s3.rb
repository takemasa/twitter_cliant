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
    file = "#{day.year}-#{month}-#{date}-#{hour}-00_#{wdays[day.wday]}_#{dir}.csv"
  elsif day.min >= 30
    file = "#{day.year}-#{month}-#{date}-#{hour}-30_#{wdays[day.wday]}_#{dir}.csv"
  end
   puts "#{file} 以外をアップロード"

   # filesはディレクトリ内のすべてのcsvファイル名
   # fileとfilesが一致しなければgz圧縮して元ファイルを削除
  files = files
  Dir.glob("*.csv").each {|all_csv_file|
    files = "#{all_csv_file}"
    if File.basename(files) != file
      tmp = nil
      gzfile = "#{File.basename(all_csv_file)}.gz"
      File.open(all_csv_file,'a+') {|f|
        tmp = f.read
      }
      Zlib::GzipWriter.open("#{all_csv_file}.gz") {|gz|
        gz.write tmp
      }
      p "delete! #{files} ------------------"
      File.delete(files)
    elsif File.basename(files) == file
      p "keep! #{File.basename(files)}^^^^^^^^^^^^^^^^^^^"
    end
    作成したgzを、ファイル名に基づいてs3内に作成したデレクトリに格納し、元ファイルを後削除
    if gzfile
      bucket = s3.buckets["dsb-twitter-test/tweets/#{dir}/#{File.basename(files)[0..3]}/#{File.basename(files)[5..6]}/#{File.basename(files)[8..9]}"]
      puts "/#{dir}/#{File.basename(files)[0..3]}/#{File.basename(files)[5..6]}/#{File.basename(files)[8..9]}/#{gzfile}"
      filename = File.basename(gzfile)
      o = bucket.objects[filename]
      o.write(:file => filename)
      File.delete(gzfile)
    end
  }
end


ec2s3(ARGV[0])