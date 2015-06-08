require "rubygems"
require "open4"
# change 2

# Get list of all files changes
if File.exist?('.last_repack')

  # Get the latest sha
  last_sha = File::read( '.last_repack' )
  
  diff_cmd = "git diff " + last_sha  + " HEAD --name-status"
  tar_cmd = "tar -cf ../repack_"+ last_sha +".tar"

  # put first line of manifest
  manifest = last_sha + "\n"
  
  # tar command prefix
  tar_cmd = tar_cmd + " reploy_manifest.txt "
  
else
  
  #cmd = "git diff  HEAD^1 HEAD --name-status"
  tar_cmd = "tar -cf ../repack_initial.tar ."

  # put first line of manifest
  manifest = "initial\n"

end

puts "Repacking..."

if diff_cmd.nil?

  puts "initial commit"
  
else

  # Executes diff command.
  pid, stdin, diffout, differr = Open4::popen4 diff_cmd
  
  puts "Repacking from commit: " + last_sha
  
  # include list of files into the tar command
  diffout.each do |file|
    manifest << file
    f = file.sub(/[\t]/, '').sub(/[MAD]/, '')

    puts "Repacking file: " + f

    f = f.sub(/[\n]/, ' ')
    tar_cmd <<  f
  end

  # Manifest contains list of the files.
  File::open( 'reploy_manifest.txt', 'w' ) do |output_file|
    output_file << manifest
  end

end

# Executes command tar to generate tar file.
pid, stdin, cmdout, cmderr = Open4::popen4 tar_cmd

# Update file .last_repack with sha of last commit
show_cmd = 'git rev-parse HEAD'
pid, stdin, showout, showerr = Open4::popen4 show_cmd

showout.each do |showout_line|
  last_sha = showout_line.sub('commit', '').strip
  break
end

File::open( '.last_repack' , 'w') do |last_repack|
  last_repack << last_sha
end

# Delete reploy_manifest.txt
system 'rm reploy_manifest.txt'

puts "Repack fineshed successful."
