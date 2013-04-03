#!/usr/bin/env ruby

load File.join(File.expand_path(File.dirname(__FILE__)), 'pmsg')

start_time = Time.now

def log message
    puts "#{Time.now.strftime('%D - %T')}: #{message}"
end

def sh cmd
    puts cmd
    puts
    system cmd
end

def usage
  msg = <<EOF
Usage: 
    #{__FILE__} Input.Movie.iso /output/dir/
EOF
  msg
end

abort usage unless ARGV[0] and ARGV[1]

mount_location = '/mnt/iso'
input_file = File.expand_path ARGV[0]
output_dir = File.expand_path ARGV[1]
abort "File does not exist #{input_file}" unless File.exist? input_file
abort "Output dir does not exist #{output_dir}" unless File.exist? output_dir
abort "Input must be an iso input_file" unless File.extname(input_file) == ".iso"
input_file_basename = File.basename(input_file, ".*")
output_file = "#{output_dir}/#{input_file_basename}.mkv"


mount_cmd = "sudo mount -o loop '#{input_file}' '#{mount_location}'"
umount_cmd = "sudo umount '#{mount_location}'"
convert_cmd = "HandBrakeCLI --min-duration 240 --main-feature --arate 48 --aencoder copy:dts,copy:ac3 --mixdown 6ch --encoder x264 --crop 0:0:0:0 --rate 23.976 --vb 6957 --ab 1510 --format mkv --input '#{mount_location}' --output '#{output_file}'"

log "Trying to mount the iso to #{mount_location}"
if not sh(mount_cmd)
    log "Unable to mount to to #{mount_location}"
    log "Trying to unmount first..."
    if sh(umount_cmd)
        log "Unmount successful. Trying to mount again"
        abort "Unable to mount to #{mount_location}" unless sh(mount_cmd)
    end
end

log "Starting the conversion. This could take a while..."
msg,title,priority=nil
if sh(convert_cmd)
    title = "Conversion Complete"
    msg = "Finished converting #{input_file_basename}"
    priority = 'normal'
else
    title = "Conversion failed!"
    msg = "Failed converting #{input_file_basename}. Check the log for details."
    priority = 'high'
end

log title
elapsed = (Time.now - start_time).to_i
secs = elapsed % 60
mins = elapsed / 60
hours = mins / 60
msg = "#{msg}. Process took #{hours}H #{mins}M #{secs}S"
PushoverMsg.new.notify(title, msg, priority)


