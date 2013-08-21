# coding: utf-8
require 'bundler/setup'
Bundler.setup
Bundler.require
require 'yaml'
require 'fileutils'

config = YAML.load_file('./config.yaml')
day = Time.now

AWS.config(
  :access_key_id => config["aws_access_key"],
  :secret_access_key => config["aws_secret_access_key"],
  :s3_endpoint => config["region"]
)
s3 = AWS::S3.new


# 第1引数は検索語句
# 第2引数は格納先バケット内のディレクトリ名
# csvファイルは現在時刻に基づいたファイル名で30分おきに作られるため、最新のファイル以外を指定してzip圧縮
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
Dir.chdir("/home/ec2-user/twitter/tweets/#{ARGV[0]}/tweet")
if day.min < 30
	file = "#{ARGV[0]}_#{day.year}-#{month}-#{date}-#{hour}-0.csv"
elsif day.min >= 30
	file = "#{ARGV[0]}_#{day.year}-#{month}-#{date}-#{hour}-30.csv"
end

puts file
dir = Dir.glob("*.csv").each {|all_csv_file|
	if all_csv_file != file
    files = "#{all_csv_file}"
    zipfile = "#{File.basename(all_csv_file)}.zip"
    Zip::Archive.open(zipfile, Zip::CREATE) do |arc|
      arc.add_file(files)
    end
    p "delete! #{all_csv_file} ------------------"
    File.delete(all_csv_file)
	elsif all_csv_file == file
		p "keep! #{all_csv_file}"
    p "keep! #{file}^^^^^^^^^^^^^^^^^^^"
	end
}
bucket = s3.buckets["dsb-twitter-test/tweets/#{ARGV[1]}"]
dir = Dir.glob("*.zip").each {|all_zip_file|
	p all_zip_file
	filename = all_zip_file
	o = bucket.objects[filename]
	o.write(:file => filename)
	File.delete(all_zip_file)
}
# checkの中身はとりあえずいらない
# bucket = s3.buckets["dsb-twitter-test/tweets/check"]
# dir = Dir.glob("/home/ec2-user/twitter/tweets/#{ARGV[0]}/check/*.txt").each {|all_txt_file|
# 	p all_txt_file
# 	filename = all_txt_file
# 	o = bucket.objects[filename]
# 	o.write(:file => filename)
# 	if !(/_id/ =~ all_txt_file)
# 		File.delete(all_txt_file)
# 	end
# }