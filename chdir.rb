# coding: utf-8
require 'bundler/setup'
Bundler.setup
Bundler.require
require 'yaml'
require 'fileutils'

Dir.chdir("../tweets/#{ARGV[0]}/tweet")
Dir.glob("*.csv").each {|all_csv_file|
	files = "#{all_csv_file}"
	FileUtils::mkdir_p("../#{files[0..3]}/#{files[5..6]}/#{files[8..9]}") unless FileTest.exist?("../#{files[0..3]}/#{files[5..6]}/#{files[8..9]}")
	FileUtils.mv("#{all_csv_file}", "../#{files[0..3]}/#{files[5..6]}/#{files[8..9]}/#{all_csv_file}")
}