#puppetdbget.rb

module Puppet::Parser::Functions
  newfunction(:puppetdbget, :type => :rvalue) do |args|
    require 'net/http'
    require 'open-uri'
    puppetdb = lookupvar('Logicmonitor::puppetdb_host')
    port = lookupvar('Logicmonitor::puppetdb_http_port')
    url = "http://#{puppetdb}/#{args[0]}"
    uri = URI(url)
    http = Net::HTTP.new(uri.host, 8080)
    req = Net::HTTP::Get.new(uri.request_uri)
    req['Accept'] = 'application/json'
    res = http.request(req)
    return res.body
  end
end
