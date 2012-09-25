#gethosts.rb

module Puppet::Parser::Functions
  newfunction(:gethosts, :type => :rvalue) do |args|
    Puppet::Parser::Functions.autoloader.loadall
    require 'json'
    portal = lookupvar('Logicmonitor::portal')
    user = lookupvar('Logicmonitor::user')
    password = lookupvar('Logicmonitor::password')
    array = []
    resp = function_apiget([portal, user, password, "/rpc/getHosts?hostGroupId=1"])
    json = JSON.parse(resp)
   if json["status"].to_s.include?("200") == true
      data = json["data"]["hosts"]
      data.each do |host|
        name = host["name"].to_s
        hostname = host["hostName"]
        array = array.push([hostname, name])
      end
    else
      raise Puppet::ParseError, json["errmsg"]
    end
    hostLookup = Hash[array]
    return hostLookup
  end
end
