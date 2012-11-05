#addlmhosts.rb

module Puppet::Parser::Functions
  newfunction(:addlmhosts, :type => :rvalue) do |args|
    Puppet::Parser::Functions.autoloader.loadall
    function_notice(["-= Starting Addition of Hosts =-"])

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
    hosts.each do |host|
      errors = 0
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
      
      function_notice(["Host name = " + hostname])

      description = host["parameters"]["description"]
      alertEnable = host["parameters"]["alertenable"].to_s

      if existing_hosts.has_key?(hostname) == false
        #find collector id
        collector_id = 0
        if collector_nodes.has_key?(host["parameters"]["collector"])
          collector_name = host["parameters"]["collector"]
          collector_id = collector_nodes[collector_name]
        elsif integer?(host["parameters"]["collector"])
          collector_info = JSON.parse(function_apiget([portal, user, password, "/rpc/getAgent?agentId=#{collector_id}"]))
          if collector_info["status"].to_i == 200
            collector_id = host["parameters"]["collector"].to_i
          else
            rval << "Collector " + host["parameters"]["collector"].to_s + " was not found. Skipping add.\n"
            errors = errors + 1
          end        
        else
          rval << "Collector " + host["parameters"]["collector"].to_s + " was not found. Skipping add.\n"
          errors = errors + 1
        end
      
        function_notice(["Collector id = " + collector_id.to_s])

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

        function_notice(["Group list = [" + groupids.to_s + "]"])
      
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
      
      
        if groupids.empty? == false
          groups = groupids.chomp(',')
          addhostquery = addhostquery + "&hostGroupIds=#{groups}"
        end # end if
      
        if errors == 0
          resp = function_apiget([portal, user, password, addhostquery])
          response_json = JSON.parse(resp)
      
          if response_json["status"].to_i == 200
            rval << "Host " + hostname + " was sucessfully added.\n"
          else
            rval << "Host " + hostname + " could not be added to the portal. ERROR: status = " + response_json["status"].to_s + "\n" 
            if response_json["errmsg"].include?("INSERT") == false
              rval << "ERROR: " + response_json["errmsg"].to_s + "\n" 
            end
          end
  #        rval << addhostquery + "\n"
        end
      end
    end
    return rval
  end
end
