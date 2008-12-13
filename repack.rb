require "rubygems"
require "open4"

# Get the latest sha
last_sha = File::read( '.last_repack' )

# Get list of all files changes
if not last_sha == ''
  cmd = "git diff " + last_sha  + " HEAD --name-status"
  tar = "tar -cf repack_"+ last_sha +".tar"

  # put first line of manifest
  manifest = last_sha + "\n"

else
  
  cmd = "git diff  HEAD^1 HEAD --name-status"
  tar = "tar -cf repack_initial.tar"

  # put first line of manifest
  manifest = "initial\n"

end

pid, stdin, diffout, differr = Open4::popen4 cmd

# tar command prefix
cmd = tar + " manifest.txt "

puts "Repacking..."
if last_sha == ''
  puts "commit: " + last_sha
else
  puts "initial commit"
end

# include list of files into the tar command
diffout.each do |file|
  manifest << file
  f = file.sub(/[\t]/, '').sub(/[MAD]/, '')
  
  puts "Repacking file: " + f
  
  f = f.sub(/[\n]/, ' ')
  cmd <<  f
end

# Manifest contains list of the files.
File::open( 'manifest.txt', 'w' ) do |output_file|
  output_file << manifest
end

pid, stdin, cmdout, cmderr = Open4::popen4 cmd

# Update file .last_repack with sha of last commit
cmd = 'git show'
pid, stdin, showout, showerr = Open4::popen4 cmd

showout.each do |showout_line|
  last_sha = showout_line.sub('commit', '').strip
  break
end

File::open( '.last_repack' , 'w') do |last_repack|
  last_repack << last_sha
end

puts "Repack fineshed successful."
