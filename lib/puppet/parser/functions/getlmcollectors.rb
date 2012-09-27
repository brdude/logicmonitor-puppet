#get all collectors in LogicMonitor portal

module Puppet::Parser::Functions
  newfunction(:getlmcollectors, :type => :rvalue) do |args|
    Puppet::Parser::Functions.autoloader.loadall
    require "rubygems"
    require "json"
     portal = lookupvar('Logicmonitor::portal')
     user = lookupvar('Logicmonitor::user')
     password = lookupvar('Logicmonitor::password')
     array = []
     resp = function_apiget([portal, user, password, "/rpc/getAgents?"])
     json = JSON.parse(resp)
    if json["status"].to_s.include?("200") == true
       data = json["data"]
       data.each do |collector|
         conf = collector["conf"]
         hostname = conf.match(/server=([a-zA-Z0-9\._]+)\\r\\n/)[1]
         id = collector["id"]
         array = array.push([hostname, id])
       end
     else
       raise Puppet::ParseError, json["errmsg"]
     end
     collectorLookup = Hash[array]
     return collectorLookup
  end
end