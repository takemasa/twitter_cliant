File.open("../linux/output/RT/#{ARGV[0]}_RT.csv","w"){|f|
	f.write ""
}
File.open("../linux/output/RT/#{ARGV[0]}_no_RT.csv","w"){|f|
	f.write ""
}
File.open("../linux/output/#{ARGV[0]}.csv") {|file|
  while line = file.gets
	  	if /RT/ =~ line
	  		File.open("../linux/output/RT/#{ARGV[0]}_RT.csv",'a'){|f|
	  			f.write "#{line}\n" 
	  		}
	  	else
	  		File.open("../linux/output/RT/#{ARGV[0]}_no_RT.csv",'a'){|f|
	  			f.write "#{line}\n" 
	  		}
	  	end
  end
}