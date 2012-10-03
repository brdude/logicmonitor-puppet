#getlmgroups.rb
#Arguments: none
#Returns: A hash e.g. {"group_name0"=>group_id0, "group_name1"=>group_id1}


module Puppet::Parser::Functions
  newfunction(:getlmgroups, :type => :rvalue) do |args|
    Puppet::Parser::Functions.autoloader.loadall
    require 'rubygems'
    require 'json'
    require 'cgi'
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
        array = array.push(["/"+name, id])
      end
    else
      raise Puppet::ParseError, json["errmsg"]
    end
    hostGroupLookup = Hash[array]
    return hostGroupLookup

  end
end
