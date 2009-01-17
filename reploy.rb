require "rubygems"
#require "open4"

repack_file_name = ''

Dir['repack_*.tar'].each do |file_name|
  puts "Reploing file: " + file_name
  tar_cmd = "tar -xf " + file_name
  repack_file_name = file_name
  system tar_cmd
  #pid, stdin, showout, showerr = Open4::popen4 tar_cmd
  break
end

j = 0

# If it's a initial deploy, there is no manifest.txt file.
unless repack_file_name == 'repack_initial.tar'
  
  File.open('reploy_manifest.txt', 'r').each do |file_manifest|
    if j == 0
      j = j + 1
      next
    end
  
    f = file_manifest.sub(/[\t]/, ',')
  
    op, file = f.split(',')
  
    case op
      when 'A'
        puts 'Add    : ' + file
      when 'M'
        puts 'Modify : ' + file
      when 'D'
        rm_cmd = "rm " + file
        #pid, stdin, showout, showerr = Open4::popen4 cmd
        system rm_cmd
      
        puts 'Delete : ' + file
    end
  
    j = j + 1
  end

end

rm_tar_cmd = "rm repack_*.tar"
#pid, stdin, showout, showerr = Open4::popen4 rm_tar_cmd
system rm_tar_cmd

# Delete reploy_manifest.txt
system 'rm reploy_manifest.txt'

puts "Reploy finished successful."

