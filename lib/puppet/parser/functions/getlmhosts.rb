#getlmhosts.rb

module Puppet::Parser::Functions
  newfunction(:getlmhosts, :type => :rvalue) do |args|
    Puppet::Parser::Functions.autoloader.loadall
    require 'rubygems'
    require 'json'
    portal = lookupvar('Logicmonitor::portal')
    user = lookupvar('Logicmonitor::user')
    password = lookupvar('Logicmonitor::password')
    h ={}
    resp = function_apiget([portal, user, password, "/rpc/getHosts?hostGroupId=1"])
    json = JSON.parse(resp)
   if json["status"].to_s.include?("200") == true
     hosts = json["data"]["hosts"]
     hosts.each do |host|
        name = host["name"].to_s
        hostname = host["hostName"]
        h = h.merge({hostname => name})
      end
    else
      raise Puppet::ParseError, json["errmsg"]
    end
    return h
  end
end
