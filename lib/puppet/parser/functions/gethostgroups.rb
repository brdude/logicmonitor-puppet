#gethostgroups.rb

module Puppet::Parser::Functions
  newfunction(:gethostgroups, :type => :rvalue) do |args|
    Puppet::Parser::Functions.autoloader.loadall
    require 'json'
    portal = lookupvar('Logicmonitor::portal')
    user = lookupvar('Logicmonitor::user')
    password = lookupvar('Logicmonitor::password')
    array = []
    resp = function_apiget([portal, user, password, "/rpc/getHostGroups?parentId=1"])
    json = JSON.parse(resp)
    if json["status"] == 200
      data = json["data"] 
      data.each do |hostgroup|
        name = hostgroup["fullPath"]
        id = hostgroup["id"]
        array = array.push([name, id])
      end
    else
      raise Puppet::ParseError, json["errmsg"]
    end
    hostGroupLookup = Hash[array]
    return hostGroupLookup
  end
end
