# lmhost.rb
#
#
#
#
#
#
# Author: Ethan Culler-Mayeno
#
#
require 'json'
require 'open-uri'

Puppet::Type.type(:lm_host).provide(:lmhost) do
  desc "This provider handles the creation, status, and deletion of hosts in your LogicMonitor account"
  
  #
  # Functions as required by ensurable types
  #
  def create
    notice("Creating LogicMonitor host \"#{resource[:hostname]}\"")
    resource[:groups].each do |group|
      if get_group(group).nil?
        notice("Couldn't find parent group #{group}. Creating.")
        created_group = recursive_group_create( group, nil, nil, true)
      end
    end
    add_resp = rpc("addHost", build_host_hash(resource[:hostname], resource[:displayname], resource[:collector], resource[:description], resource[:groups], resource[:properties], resource[:alertenable]))
    #notice add_resp
  end

  def destroy
    notice("Removing LogicMonitor host  \"#{resource[:hostname]}\"")
    host = get_host_by_displayname(resource[:displayname]) || get_host_by_hostname(resource[:hostname], resource[:collector])
    if host
      delete_resp = rpc("deleteHost", {"hostId" => host["id"], "deleteFromSystem" => true})
      #notice(delete_resp)
    end
  end

  def exists?
    notice("Checking LogicMonitor for host #{resource[:hostname]}")
    retval = get_host_by_displayname(resource[:displayname]) || get_host_by_hostname(resource[:hostname], resource[:collector])
    retval
  end

  #
  # Display name get and set functions
  #
  def displayname
    notice("Checking displayname on #{resource[:hostname]}")
    disp_name = ""
    host = get_host_by_displayname(resource[:displayname]) || get_host_by_hostname(resource[:hostname], resource[:collector])
    if host
      disp_name << host["displayedAs"]
    end
    disp_name
  end
  
  def displayname=(value)
    notice("Updating displayname on #{resource[:hostname]}")
    update_host(resource[:hostname], value, resource[:collector], resource[:description], resource[:groups], resource[:properties], resource[:alertenable])
  end

  #
  # Description get and set functions
  #
  def description
    notice("Checking the long text description on  #{resource[:hostname]}")
    desc = ""
    host = get_host_by_displayname(resource[:displayname]) || get_host_by_hostname(resource[:hostname], resource[:collector])
    if host
      desc << host["description"]
    end
    desc
  end

  def description=(value)
    notice("Updating the long text description on #{resource[:hostname]}")
    update_host(resource[:hostname], resource[:displayname], resource[:collector], value, resource[:groups], resource[:properties], resource[:alertenable])
  end

  #
  # Monitoring collector get and set functions
  #
  def collector
    notice("Checking for existence of a collector on #{resource[:collector]}")
    collector = nil
    host = get_host_by_displayname(resource[:displayname]) || get_host_by_hostname(resource[:hostname], resource[:collector])
    if host
      agent_json = rpc("getAgent", {"id" => host["agentId"]})
      agent_resp = JSON.parse(agent_json)
      if agent_resp["status"] == 200
        collector = agent_resp["data"]["description"]
      else
        notice("Unable to retrieve collector list from server")
      end
    end
    collector
  end

  def collector=(value)
    notice("Setting monitoring collector to #{resource[:collector]}")
    update_host(resource[:hostname], resource[:displayname], value, resource[:description], resource[:groups], resource[:properties], resource[:alertenable])
  end


  #
  # Alert enable get and set functions
  #
  def alertenable
    notice("Checking if alerting is enabled on #{resource[:hostname]}")
    host = get_host_by_displayname(resource[:displayname]) || get_host_by_hostname(resource[:hostname], resource[:collector])
    host["alertEnable"].to_s
  end

  def alertenable=(value)
    notice("Updating alerting for #{resource[:hostname]}")
    _host(resource[:hostname], resource[:displayname], resource[:collector], resource[:description], resource[:groups], resource[:properties], value)
  end

  #
  # Group membership get and set functions
  #
  def groups
    notice("Checking for group memberships for #{resource[:hostname]}")
    host = get_host_by_displayname(resource[:displayname]) || get_host_by_hostname(resource[:hostname], resource[:collector])
    host["fullPathInIds"].each do |path|
      host_group_resp = rpc("getHostGroup", {"hostGroupId" => path[-1]})
      notice(host_group_resp)
    end
  end

  def groups=(value)
    notice("Updating the set of group memberships for  #{resource[:hostname]}")
    #update_host(resource[:hostname], resource[:displayname], resource[:collector], resource[:description], value, resource[:properties], resource[:alertenable])
  end

  #
  # Property functions for checking and setting properties on a host
  #
  def properties
    notice("Verifying properties for #{resource[:hostname]}")
  
  end

  def properties=(value)
    notice("Updating properties for #{resource[:hostname]}")
    #update_host(resource[:hostname], resource[:displayname], resource[:collector], resource[:description], resource[:groups], value, resource[:alertenable])
  end
  #
  # Utility functions within the provider
  #

  #update a host

  def update_host(hostname, displayname, collector, description, groups, properties, alertenable)
    host = get_host_by_displayname(displayname) || get_host_by_hostname(hostname, collector)
    h = build_host_hash(hostname, displayname, collector, URI::encode(description), groups, properties, alertenable)
    if host
      h.store("id", host["id"])
    end
    update_resp = rpc("updateHost", h)
    notice(update_resp)
  end

  #return a host object from displayname
  def get_host_by_displayname(displayname)
    host = nil
    host_json = rpc("getHost", {"displayName" => URI::encode(displayname)})
    #notice(host_json)
    host_resp = JSON.parse(host_json)
    if host_resp["status"] == 200
      host = host_resp["data"]
#      notice("Found host matching #{displayname}")
    end
    host
  end
  
  #requires hostname and collector
  def get_host_by_hostname(hostname, collector)
    host = nil
    hosts_json = rpc("getHosts", {"hostGroupId" => 1})
    hosts_resp = JSON.parse(hosts_json)
    collector_resp = JSON.parse(rpc("getAgents", {}))
    if hosts_resp["status"] == 200
      hosts_resp["data"]["hosts"].each do |h|
        if h["hostName"].eql?(hostname)
#          notice("Found host with matching hostname: #{resource[:hostname]}")
#          notice("Checking agent match")
          if collector_resp["status"] == 200
            collector_resp["data"].each do |c|
              if c["description"].eql?(collector)
                host = h
              end
            end
          else
            notice("Unable to retrieve collector list from server")
          end
        end
      end
    else
      notice("Unable to retrieve host list from server" )
    end
    host
  end
  # create hash for add host RPC
  def build_host_hash(hostname, displayname, collector, description, groups, properties, alertenable)
    h = {}
    h.store("hostName", hostname)
    h.store("displayedAs", displayname)
    agent = get_agent(collector)
    if agent
      h.store("agentId", agent["id"])
    end
    if description
      h.store("description", description)
    end
    group_ids = ""
    groups.each do |group|
      group_ids << get_group(group)["id"].to_s
      group_ids << ","
    end
    h.store("hostGroupIds", group_ids.chop)
    h.store("alertEnable", alertenable)
    index = 0
    unless properties.nil?
      properties.each_pair do |key, value|
        h.store("propName#{index}", key)
        h.store("propValue#{index}", value)
        index = index + 1
      end
    end
    h.store("propName#{index}", "puppet.update.on") 
    h.store("propValue#{index}", DateTime.now().to_s)
    h
  end

  def get_agent(description)
    agents = JSON.parse(rpc("getAgents", {}))
    ret_agent = nil
    if agents["data"]
      agents["data"].each do |agent|
        if agent["description"].eql?(description)
          ret_agent = agent
        end
      end
    else
      notice("Unable to get list of collectors from the server")
    end
    ret_agent
  end

  #Build the proper hash for the RPC function
  def build_group_param_hash(fullpath, description, properties, alertenable, parent_id)
    path = fullpath.rpartition("/")
    hash = {"name" => path[2]}
    hash.store("parentId", parent_id)
    hash.store("alertEnable", alertenable)
    unless description.nil?
        hash.store("description", URI::encode(description))
    end
    index = 0
    unless properties.nil?
      properties.each_pair do |key, value|
        hash.store("propName#{index}", key)
        hash.store("propValue#{index}", value)
        index = index + 1
      end
    end
    hash.store("propName#{index}", "puppet.update.on") 
    hash.store("propValue#{index}", DateTime.now().to_s)
    hash
  end

  # handle creation of all groups needed for the host to exist.
  def recursive_group_create(fullpath, description, properties, alertenable)
    path = fullpath.rpartition("/")
    parent_path = path[0]
#    notice("checking for parent: #{path[2]}")
    parent_id = 1
    if parent_path.nil? or parent_path.empty?
      notice("highest level")
    else
      parent = get_group(parent_path)
      if not parent.nil?
#        notice("parent group exists")
        parent_id = parent["id"]
      else
        parent_ret = recursive_group_create(parent_path, nil, nil, true) #create parent group with basic information.
        unless parent_ret.nil?
          parent_id = parent_ret
        end
      end
    end
    hash = build_group_param_hash(fullpath, description, properties, alertenable, parent_id)
    resp_json = rpc("addHostGroup", hash)
    resp = JSON.parse(resp_json)
    if resp["data"].nil?
      nil
    else
      resp["data"]["id"]
    end
  end

  # return a group object if "fullpath" exists or nil
  def get_group(fullpath)
    returnval = nil 
    group_list = JSON.parse(rpc("getHostGroups", {}))
    if group_list["data"].nil? 
      notice("Unable to retrieve list of host groups from LogicMonitor Account")
    else
      group_list["data"].each do |group|
        if group["fullPath"].eql?(fullpath.sub("/", ""))    #Check to see if group exists          
          returnval = group
        end
      end
    end
    returnval
  end

  # Simplifies the calling of LogicMonitor RPCs
  def rpc(action, args={})
    company = resource[:account]
    username = resource[:user]
    password = resource[:password]
    url = "https://#{company}.logicmonitor.com/santaba/rpc/#{action}?"
    first_arg = true
    args.each_pair do |key, value|
      url << "#{key}=#{value}&"
    end
    url << "c=#{company}&u=#{username}&p=#{password}"
#    notice(url)
    uri = URI(url)
    begin
      http = Net::HTTP.new(uri.host, 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(req)
      return response.body
    rescue SocketError => se
      puts "There was an issue communicating with #{url}. Please make sure everything is correct and try again."
    rescue Error => e
      puts "There was an issue."
      puts e.message
    end
    return nil
  end

end
