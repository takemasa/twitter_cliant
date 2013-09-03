require "fileutils"
Dir.chdir("../tweets/#{ARGV[0]}")


hit = []
no_hit = []
csv_length = 0
all_csv_length = 0
sum_num = 0
sum_ary = []
sum_hit = []



Dir.glob("*/*/*/*.csv").each {|all_csv_file|
	i = 0
	k = 0
	csv_length = 0
	File.open("#{all_csv_file}") {|f|
		while line = f.gets
			if !line.include?(ARGV[1])
				no_hit[k] = "#{line}"
				k += 1
			else
				hit[i]  = "#{line}" 
				i += 1
			end
			csv_length += 1
		end
	}

	puts sum_hit[sum_num] = "sum:#{csv_length} hit:#{i} No:#{k} #{File.basename(all_csv_file)}"
	sum_ary[sum_num] = "#{File.basename(all_csv_file)},#{i},#{k},#{csv_length}\n"
	all_csv_length += csv_length
	sum_num += 1
}

num_num = 0
File.open("../#{ARGV[0]}_qsum.txt",'a'){|sum|
	sum.write "\ntotal_sum   = #{all_csv_length}\n"
}
until num_num >= sum_num 
File.open("../#{ARGV[0]}_qsum.csv",'a'){|sum|
		sum.write sum_ary[num_num]
	}
File.open("../#{ARGV[0]}_qsum.txt",'a'){|sum|
	sum.write "#{sum_hit[num_num]}\n"
}
	num_num += 1
end
