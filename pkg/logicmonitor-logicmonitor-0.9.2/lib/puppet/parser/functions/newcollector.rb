#newcollector.rb

module Puppet::Parser::Functions
  newfunction(:newcollector, :type => :rvalue) do |args| 
    Puppet::Parser::Functions.autoloader.loadall
    require 'json'
    portal = lookupvar('Logicmonitor::portal')
    user = lookupvar('Logicmonitor::user')
    password = lookupvar('Logicmonitor::password')
    puts "Creating collector"
    newCollectorStatus = function_apiget( [portal, user, password, "/rpc/addAgent?autogen=true"])

    json = JSON.parse(newCollectorStatus)

    if json["status"] != 200
      id = -1
    else
      id = json["data"]["id"]
    end
    id
  end
end
