# "dir/date/*.csv"ファイルをkeywordで検索し、ヒットしたものを出力
def search_keyword(keyword,dir,date)
	require "fileutils"
	day = Time.now

	hit = []
	csv_length = 0
	all_csv_length = 0
	sum_num = 0
	sum_ary = []
	s = 0
	if keyword  != nil && dir != nil
		puts "search #{keyword} from #{dir}/#{date}*.csv"
		Dir.chdir("work")
		FileUtils::mkdir_p("#{dir}_in_#{keyword}/sum") unless FileTest.exist?("#{dir}_in_#{keyword}/sum")
		Dir.glob("#{dir}/#{date}*.csv").each {|all_csv_file|
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
				File.open("#{dir}_in_#{keyword}/#{File.basename(all_csv_file)}",'a'){|hit_word|
					hit_word.write hit[num]
				}
				num += 1
			end
		}

		num_num = 0
		until num_num >= sum_num 
		File.open("#{dir}_no_#{keyword}/sum/sum_#{dir}_no_#{keyword}_#{day.month}#{day.day}.csv",'a'){|sum|
				sum.write sum_ary[num_num]
			}
			num_num += 1
		end

		File.open("#{dir}_in_#{keyword}/sum/sum_#{dir}_in_#{keyword}.txt",'a'){|sum|
			sum.write "#{day}\nキーワード: #{keyword}\ntotal_sum  = #{s} / #{all_csv_length}\n"
		}
	else
		puts "search keyword from dir/yyyy/mm/dd/*.csv"
		puts "input keyword dir yyyy/mm/dd/"
	end
end



search_keyword(ARGV[0],ARGV[1],ARGV[2])