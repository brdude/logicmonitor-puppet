#puppetdbget.rb

#This function provides takes 2 arguments. The path for the puppetdb rest API and the optional query
#Returns the response body


module Puppet::Parser::Functions
  newfunction(:puppetdbget, :type => :rvalue) do |args|
    require 'net/http'
    require 'open-uri'
    require 'cgi'
    path = args[0]
    query = nil
    if args.length > 1
      query = args[1]
    end
    puppetdb = lookupvar('Logicmonitor::puppetdb_host')
    port = lookupvar('Logicmonitor::puppetdb_http_port')
    url = "http://"+ puppetdb + path.chomp('/')
    if query != nil
      url << "?query=" + CGI::escape(query)
    end
    uri = URI(url)
    http = Net::HTTP.new(uri.host, 8080)
    req = Net::HTTP::Get.new(uri.request_uri)
    req['Accept'] = 'application/json'
    res = http.request(req)
    return res.body
  end
end