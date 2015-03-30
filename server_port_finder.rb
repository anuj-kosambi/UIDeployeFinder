#!/usr/bin/ruby -w
$PORT = 8080
$DEFAULT_IP = "172.16."
$TIMEOUT = 3
$SCRIPT_NAME = "server_port_finder"
ip_index = ARGV.index("--ip")
max_connection_timeout_index = ARGV.index "--timeout"

def to_int(string)
  Integer(string || '')
rescue ArgumentError
  nil
end

def usages
  puts "./#{$SCRIPT_NAME} #For default_ip and default timeout"
  puts "./#{$SCRIPT_NAME} --ip aa.bb.<int>.xx #For aa.bb.00.00 to aa.bb.<int>.254"
  puts "./#{$SCRIPT_NAME}  --ip aa.bb.xx.xx #For aa.bb.00.00 to aa.bb.254.254"
  puts "./#{$SCRIPT_NAME} --timeout 3 #to change timeout"
end

if max_connection_timeout_index && max_connection_timeout_index + 1 < ARGV.count

end

if ip_index &&  ip_index+1 < ARGV.count
  $IP  = ARGV[ip_index+1]
  ip_array = $IP.to_s.split(".")
  if ip_array.count != 4
    usages
    exit(-1)
  end

  $IP = ip_array[0]+"."+ip_array[1]+"."
  if to_int(ip_array[2])==nil
    third_part = (0..254)
  else
    last_ip = to_int(ip_array[2])
    third_part = (0..last_ip)
  end
else
  $IP = $DEFAULT_IP
  third_part = (0..254)
end



forth_part = (0..254)
outer_threads = third_part.map do |j|
  puts "Checking in range #{$IP}#{j}.X..."
  threads = forth_part.map do |i|
    Thread.new(i) do |i|
      ip = "#{$IP}#{j}.#{i}"
      #puts "Checking #{ip}"
      output = system("2>/dev/null curl -m #{$TIMEOUT} #{ip}:#{$PORT} 1>/dev/null")
      puts "OK:-------#{ip}--------\n" if output
    end
  end
  threads.each {|t| t.join}
  threads
end
outer_threads.each {|t| t.join }
puts "###  Complete!!   ###"

