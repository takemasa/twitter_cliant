require "fileutils"

FileUtils::mkdir_p("../tweets/output/#{ARGV[0]}/rt/origin") unless FileTest.exist?("../tweets/output/#{ARGV[0]}/rt/origin")
FileUtils::mkdir_p("../tweets/output/#{ARGV[0]}/rt/sum") unless FileTest.exist?("../tweets/output/#{ARGV[0]}/rt/sum")


rt = []
no_rt = []
csv_length = 0
all_csv_length = 0
sum_num = 0
sum_ary = []

Dir.chdir("../tweets/output/#{ARGV[0]}")

Dir.glob("*.csv").each {|all_csv_file|
	i = 0
	k = 0
	csv_length = 0
	File.open("#{all_csv_file}") {|f|
		while line = f.gets
			if !(/RT / =~ line)# && !(/【定期】/ =~ line)
				no_rt[k] = "#{line}"
				k += 1
			else
				rt[i]  = "#{line}" 
				i += 1
			end
			csv_length += 1
		end
	}

	puts "sum:#{csv_length} RT:#{i} No:#{k} #{all_csv_file}"
	sum_ary[sum_num] = "#{i},#{k},#{csv_length},#{all_csv_file}\n"
	all_csv_length += csv_length
	sum_num += 1
	num = 0
	until num >= i && num >= k
		if num <= i && num <= k
			File.open("rt/rt_#{all_csv_file}",'a'){|hit_rt|
				hit_rt.write rt[num]
			}
			File.open("rt/no_rt_#{all_csv_file}",'a'){|no_hit_rt|
				no_hit_rt.write no_rt[num]
			}
		elsif num > i
			File.open("rt/no_rt_#{all_csv_file}",'a'){|no_hit_rt|
				no_hit_rt.write no_rt[num]
			}
		elsif num > k
			File.open("rt/rt_#{all_csv_file}",'a'){|hit_rt|
				hit_rt.write rt[num]
			}
		end
		num += 1
	end

	FileUtils.mv("#{all_csv_file}", "rt/origin/#{all_csv_file}")
}

num_num = 0
until num_num >= sum_num 
File.open("../rt/sum/#{ARGV[0]}_sum.csv",'a'){|sum|
		sum.write sum_ary[num_num]
	}
	num_num += 1
end

File.open("../rt/sum/#{ARGV[0]}_sum.txt",'a'){|sum|
	sum.write "total_sum   = #{all_csv_length}\n"
}