# "dir/yyyy/mm/dd/*.csv"ファイルをkeywordで検索し、ヒットしたものを出力
def search_keyword(keyword,dir,yyyy,mm,dd)
	require "fileutils"
	day = Time.now

	if yyyy == nil
		yyyy = "*"
	end
	if mm == nil
		mm = "*"
	end
	if dd == nil
		dd = "*"
	end

	hit = []
	csv_length = 0
	all_csv_length = 0
	sum_num = 0
	sum_ary = []
	s = 0
	Dir.chdir("../tweets/#{dir}")
	FileUtils::mkdir_p("../#{dir}_include_#{keyword}") unless FileTest.exist?("../#{dir}_include_#{keyword}")
	Dir.glob("#{yyyy}/#{mm}/#{dd}/*.csv").each {|all_csv_file|
		i = 0
		k = 0
		csv_length = 0
		File.open("#{all_csv_file}") {|f|
			while line = f.gets
				if !line.include?("#{keyword}")# && !(/【定期】/ =~ line)
					k += 1
				else
					hit[i]  = "#{line}" 
					i += 1
					s += 1
				end
				csv_length += 1
			end
		}

		puts "sum:#{csv_length} Hit:#{i} No:#{k} #{File.basename(all_csv_file)}"
		sum_ary[sum_num] = "#{i},#{k},#{csv_length},#{File.basename(all_csv_file)}\n"
		all_csv_length += csv_length
		sum_num += 1
		num = 0
		until num >= i
			File.open("../#{dir}_include_#{keyword}/#{File.basename(all_csv_file)}",'a'){|hit_word|
				hit_word.write hit[num]
			}
			num += 1
		end
	}

	num_num = 0
	until num_num >= sum_num 
	File.open("../#{dir}_include_#{keyword}/sum_#{dir}_include_#{keyword}.csv",'a'){|sum|
			sum.write sum_ary[num_num]
		}
		num_num += 1
	end

	File.open("../#{dir}_include_#{keyword}/sum_#{dir}_include_#{keyword}.txt",'a'){|sum|
		sum.write "キーワード#{keyword}\ntotal_sum  = #{s} / #{all_csv_length}\n"
	}
end



search_keyword(ARGV[0],ARGV[1],ARGV[2],ARGV[3],ARGV[4])