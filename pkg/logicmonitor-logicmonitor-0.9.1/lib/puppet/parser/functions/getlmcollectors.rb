#getlmcollectors.rb

module Puppet::Parser::Functions
  newfunction(:getlmcollectors, :type => :rvalue) do |args|
    Puppet::Parser::Functions.autoloader.loadall
    require 'rubygems'
    require 'json'
    require 'cgi'
    portal = lookupvar('Logicmonitor::portal')
    user = lookupvar('Logicmonitor::user')
    password = lookupvar('Logicmonitor::password')
    a = []
    resp = function_apiget([portal, user, password, "/rpc/getAgents?"])
    json = JSON.parse(resp)
    if json["status"] == 200
      data = json["data"]
      data.each do |collector|
        a = a.push(collector["id"])
      end
    else
      raise Puppet::ParseError, json["errmsg"]
    end

    return a

  end
end
