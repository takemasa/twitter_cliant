# coding: utf-8
require 'bundler/setup'
Bundler.setup
Bundler.require
require 'yaml'
require 'fileutils'

def unzip_mvdir(keyword)
  if keyword != nil
    Dir.glob("work/#{keyword}/*/*/*/*.zip").each {|all_csv_file|
      Zip::Archive.open("#{all_csv_file}") do |ar|
        ar.each do |zf|
            if zf.directory?
              FileUtils.mkdir_p(zf.name)
            else
              dirname = File.dirname(all_csv_file)
              FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
              open(zf.name, 'wb') do |f|
                f << zf.read
              end
            end
          end
        end
      }
    Dir.glob("*.csv").each {|all_csv_file|
      files = "#{all_csv_file}"
      FileUtils::mkdir_p("work/#{keyword}/#{files[0..3]}/#{files[5..6]}/#{files[8..9]}") unless FileTest.exist?("../#{files[0..3]}/#{files[5..6]}/#{files[8..9]}")
      FileUtils.mv("#{files}", "work/#{keyword}/#{files[0..3]}/#{files[5..6]}/#{files[8..9]}/#{files}")
      p all_csv_file
    }
    Dir.glob("work/#{keyword}/*/*/*/*.zip").each {|all_zip_file|
      File.delete(all_zip_file)
    }
  end
end

def s3toec2(dir_date,keyword)
    day = Time.now
  config = YAML.load_file('./config.yaml')

  AWS.config(
    :access_key_id => config["aws_access_key"],
    :secret_access_key => config["aws_secret_access_key"],
    :s3_endpoint => config["region"]
  )
  s3 = AWS::S3.new

  if dir_date == nil && keyword != nil
    puts "input date yyyy/mm/dd"
  end
  if keyword != nil
    dir_name = config[keyword]
  elsif dir_date != nil && keyword == nil
    puts "input keyword"
  end

  if dir_date != nil && keyword != nil
    puts "from tweets/#{dir_name}#{dir_date}"
    bucket = s3.buckets["dsb-twitter-test"]
    objects = bucket.objects.with_prefix("tweets/#{dir_name}/#{dir_date}")
    
    objects.each do |all_file|
      o = all_file.key
      puts "download #{o}"
      filename = File.basename(o)
      FileUtils::mkdir_p("work/#{dir_name}/#{filename[0..3]}/#{filename[5..6]}/#{filename[8..9]}") unless FileTest.exist?("work/#{dir_name}/#{filename[0..3]}/#{filename[5..6]}/#{filename[8..9]}")
      File.open("work/#{dir_name}/#{filename[0..3]}/#{filename[5..6]}/#{filename[8..9]}/#{filename}", 'wb') do |file|
        object = bucket.objects["#{o}"]
        object.read do |chunk|
          file.write(chunk)
        end
      end
    end
    unzip_mvdir(config[keyword])
  else
    puts "input date and keyword  ex) yyyy/mm/dd keyword"
  end
end

s3toec2(ARGV[0],ARGV[1])