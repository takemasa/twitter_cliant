require "fileutils"
 # work/targetの"を全角に置換
str = []
target = ARGV[0]
if target == nil
	puts "input dir keyword/yyyy/mm/dd/filename in work/"
elsif target.scan("/").length == 4
	Dir.glob("work/#{target}").each {|all_csv_file|
		count = 0
		str_num = 0
		num = 0
		File.open("#{all_csv_file}") {|f|
			p File.basename(all_csv_file)
			while line = f.gets
				if line.include?("\"")
					puts "#{File.basename(all_csv_file)} L#{str_num + 1}"
					count += 1
				end
				str[str_num] = line.gsub("\"","”")
				str_num += 1
			end
		}

		if count != 0
			p "#{File.basename(all_csv_file , ".csv")}_gsub.csv generate!"
			File.open("#{File.dirname(all_csv_file)}/#{File.basename(all_csv_file , ".csv")}_gsub.csv","w")
			until num >= str_num
				File.open("#{File.dirname(all_csv_file)}/#{File.basename(all_csv_file , ".csv")}_gsub.csv","a") {|f|
					f.write str[num]
				}
				num += 1
			end
			File.delete(all_csv_file)
			puts "delete #{File.basename(all_csv_file)}"
		else
			puts "no \" in #{File.basename(all_csv_file)}"
		end
	}
else
	puts "input dir keyword/yyyy/mm/dd/filename in work/"
end