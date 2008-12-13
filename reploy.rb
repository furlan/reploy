require "rubygems"
require "open4"

Dir['repack_*.tar'].each do |file_name|
  cmd = "tar -xf " + file_name
  #pid, stdin, showout, showerr = Open4::popen4 cmd
  break
end

j = 0

File.open('manifest.txt', 'r').each do |file_manifest|
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
      cmd = "rm " + file
      pid, stdin, showout, showerr = Open4::popen4 cmd
      
      puts 'Delete : ' + file
  end
  
  j = j + 1
end


cmd = "rm repack_*.tar"
#pid, stdin, showout, showerr = Open4::popen4 cmd

puts "Reploy finished successful."

