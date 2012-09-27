#addlmhosts.rb

module Puppet::Parser::Functions
  newfunction(:addlmhosts, :type => :rvalue) do |args|
    Puppet::Parser::Functions.autoloader.loadall
    require 'rubygems'
    require 'cgi'
    require 'json'
    portal = lookupvar('Logicmonitor::portal')
    user = lookupvar('Logicmonitor::user')
    password = lookupvar('Logicmonitor::password')
    returnVal = []
    collectorNodes = function_getcollectornodes([])
    lmHosts = function_gethosts([])
    lmGroups = function_gethostgroups([])

    hostReq = 'resources?query=' + CGI::escape('["and", ["=", "type", "Class"],  ["=", "title", "Logicmonitor::Host"]]')
    hostnodes = function_puppetdbget([hostReq])
    host_json = JSON.parse(hostnodes)
    addhostquery = ""
    host_json.each do |node|
      
      hostname = node["parameters"]["ipaddress"]
      displayname = node["parameters"]["display_name"]
      description = node["parameters"]["description"]
      alertEnable = node["parameters"]["alert_enable"]
      #only perform the following actions if the host has not already been addeed to monitoring
      if lmHosts["#{hostname}"] == nil      
        collectorid = 0
        #handle the collector id information
        collector = node["parameters"]["collector"]
        #Will not be nil if they passed the fqdn of the collector, should be nil if they passed it as a collector
        if collectorNodes["#{collector}"] != nil
          collectorid = collectorNodes[collector]
        elsif collector.to_i != 0
          collectorid = collector 
        else
          raise Puppet::ParseError, "Collector does not exist"
        end #end if
        
        
        #handle groups
        groupids = ""
        grouplist = node["parameters"]["groups"]
        grouplist.each do |group|
          if lmGroups["#{group}"] != nil
            groupids << lmGroups["#{group}"].to_s
            groupids << ","
          else
            raise Puppet::ParseError, "Group #{group} does not exist"
          end #end if
        end #end grouplist.each
        
        #handle properties
        propsHash = node["parameters"]["properties"]
        
        
        #handle request string
        
        addhostquery << "/rpc/addHost?"
        addhostquery << "hostName=#{hostname}"
        addhostquery << "&displayedAs=#{displayname}"
        if description.include?("UNSET") == false
          addhostquery = addhostquery + "&description=#{CGI::escape(description)}"
        end #end if
        addhostquery << "&alertEnable=#{alertEnable}"
        i = 0
        propsHash.each_pair do |key, value|
          addhostquery = addhostquery + "&propName#{i}=#{key}&propValue#{i}=#{value}"
          i = i + 1
        end #end propHash.each


        if grouplist.size() > 0
          groups = groupids.chomp(',')
          addhostquery = addhostquery + "&hostGroupIds=#{groups}"
        end # end if

 #       returnVal = addhostquery
        returnVal = returnVal.push(function_apiget([portal, user, password, addhostquery]))

      end #end if host exist
    end #end host_json.each
    
    return {"responses" => returnVal}
  end #end newfunction 
end #end module
