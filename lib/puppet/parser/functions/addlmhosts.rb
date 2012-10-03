#addlmhosts.rb

module Puppet::Parser::Functions
  newfunction(:addlmhosts, :type => :rvalue) do |args|
    Puppet::Parser::Functions.autoloader.loadall

    def integer?(object)
      true if Integer(object) rescue false
    end

    portal = lookupvar('Logicmonitor::portal')
    user = lookupvar('Logicmonitor::user')
    password = lookupvar('Logicmonitor::password')
    existing_hosts = function_getlmhosts([])
    existing_groups = function_getlmgroups([])
    existing_collectors = function_getlmcollectors([])
    collector_nodes = function_getcollectornodes([])
    host_nodes = function_puppetdbget(["/resources", '["and", ["=", "type", "Class"], ["=", "title", "Logicmonitor::Host"]]'])
    rval = ""
    hosts = JSON.parse(host_nodes)
    #rval << existing_hosts.to_s + "\n"
    hosts.each do |host|
      if host["parameters"]["ip_address"].nil? or host["parameters"]["ip_address"].include?("UNSET")
        hostname = host["parameters"]["host_name"]
      else
        hostname = host["parameters"]["ip_address"]
      end

      if host["parameters"]["display_name"].nil? or host["parameters"]["display_name"].include?("UNSET")
        displayname = host["parameters"]["host_name"]
      else
        displayname = host["parameters"]["display_name"]
      end
      
      description = host["parameters"]["description"]
      alertEnable = host["parameters"]["alert_enable"]
      
      #find collector id
      collector_id = 0
      if collector_nodes.has_key?(host["parameters"]["collector"])
        collector_name = host["parameters"]["collector"]
        collector_id = collector_nodes[collector_name]
      elsif integer?(host["parameters"]["collector"])
        collector_id = host["parameters"]["collector"].to_i
      else
        rval << "Collector " + host["parameters"]["collector"] + " was not found. Skipping add.\n"
      end
      
      #handle groups
      groupids = ""
      grouplist = host["parameters"]["groups"]
      grouplist.each do |group|
        if existing_groups[group]
          groupids << existing_groups[group].to_s
          groupids << ","
        elsif group.eql?('/')
          rval << "Skipping addition to the root group. If no host groups are specified the host will show up at the top level.\n"
        else
          rval << "Group " + group + " does not exist. Skipping addition to group " + group + " for host "+ hostname +  "\n"
        end
      end
      
      #handle properties
      
      properties = Hash[host["parameters"]["properties"]]
      
      addhostquery = "/rpc/addHost?"
      addhostquery << "hostName=#{hostname}"
      addhostquery << "&displayedAs=#{CGI::escape(displayname)}"
      addhostquery << "&agentId=#{collector_id}"
      
      if description.nil? == false && description.include?("UNSET") == false
        addhostquery = addhostquery + "&description=#{CGI::escape(description)}"
      end #end if
      addhostquery << "&alertEnable=#{alertEnable}"
      i = 0
      
      properties.each_pair do |key, value|
        addhostquery = addhostquery + "&propName#{i}=#{key}&propValue#{i}=#{value}"
        i = i + 1
      end #end propHash.each
      
      
      if grouplist.size() > 0
        groups = groupids.chomp(',')
        addhostquery = addhostquery + "&hostGroupIds=#{groups}"
      end # end if
      #rval << addhostquery + "\n"
      resp = function_apiget([portal, user, password, addhostquery])
      response_json = JSON.parse(resp)

      if response_json["status"].to_i == 200
        rval << "Host " + hostname + " was sucessfully added.\n"
      else
        rval << "Host " + hostname + " could not be added to the portal. " + response_json["errmsg"] + "\n" 
      end
      
    end
    
    return rval
  end
end
