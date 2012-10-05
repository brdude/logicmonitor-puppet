#!/usr/bin/ruby

require 'net/http'
require 'net/https'

COMPANY = ARGV[0]
USERNAME = ARGV[1]
PASSWORD = ARGV[2]
ID = ARGV[3]

def downloadCollector(id)
  puts "Downloading collector ID# " + id
  f = File.new("logicmonitorsetup#{id}.bin", "w+")
  File.chmod(0755, "logicmonitorsetup#{id}.bin")
  downloadStatus = apiGet("/do/logicmonitorsetup?id=#{id}")
  f.write(downloadStatus)
  f.close()
  if downloadStatus.size() > 10000
    puts "Download complete"
  else
    puts "Download failed"
    return -1
  end
  return 0
end

def installCollector(id)
  puts "Installing Collector"
  output = `./logicmonitorsetup#{id}.bin -y`    
  puts output
  puts "Install Completed"
  return 0
end

def apiGet(action)
  url = "https://#{COMPANY}.logicmonitor.com/santaba#{action}&c=#{COMPANY}&u=#{USERNAME}&p=#{PASSWORD}"
  uri = URI(url)
  http = Net::HTTP.new(uri.host, 443)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE      #Currently a fix. Will be removed in future releases
  req = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(req)
  return response.body
end

downloadCollector(ID)
installCollector(ID)
