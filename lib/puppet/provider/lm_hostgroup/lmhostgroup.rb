# lmhostgroup.rb
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

Puppet::Type.type(:lm_hostgroup).provide(:lmhostgroup) do
  desc "This provider handles the creation, status, and deletion of collector objects"
  
  #
  # Functions as required by ensurable types
  #
  def create
    notice("Creating LogicMonitor host group \"#{resource[:fullpath]}\"")
    recursive_create(resource[:fullpath], resource[:description], resource[:properties], resource[:alertenable])
  end

  def destroy
    notice("Removing LogicMonitor host group \"#{resource[:fullpath]}\"")
    host_group = get_group(resource[:fullpath])
    unless host_group.nil?
      ret = rpc("deleteHostGroup", {"hgId" => host_group["id"], "deleteHosts" => false})
    end  
  end

  def exists?
    notice("Checking for hostgroup #{resource[:fullpath]}")
    get_group(resource[:fullpath])
  end

  #
  # Description get and set functions
  #

  def description
    notice("Verifying description for #{resource[:fullpath]}")
    remote_group = get_group(resource[:fullpath])
    remote_group["description"]
  end

  def description=(value)
    notice("Updating description for #{resource[:fullpath]}")
    group = get_group(resource[:fullpath])
    hash = build_param_hash(resource[:fullpath], resource[:description], resource[:properties], resource[:alertenable], group["parentId"])
    hash.store("id", group["id"])
    response = rpc("updateHostGroup", hash)
 #   notice(response)
  end

  #
  # Alert enable get and set functions
  #

  def alertenable
    notice("Verifying alerting status for #{resource[:fullpath]}")
    remote_group = get_group(resource[:fullpath])
    remote_group["alertEnable"].to_s
  end

  def alertenable=(value)
    notice("Updating alerting status for #{resource[:fullpath]}")
    group = get_group(resource[:fullpath])
    hash = build_param_hash(resource[:fullpath], resource[:description], resource[:properties], resource[:alertenable], group["parentId"])
    hash.store("id", group["id"])
    response = rpc("updateHostGroup", hash)
#    notice(response)
  end

  #
  # Property functions for checking and setting properties on a host group
  #
  def properties
    notice("Verifying properties for #{resource[:fullpath]}")
    remote_group = get_group(resource[:fullpath])
    if remote_group.nil?
      notice("Unable to retrive host group information from LogicMonitor")
    else
      remote_details = rpc("getHostGroup", {"hostGroupId" => remote_group["id"], "onlyOwnProperties" => true})
      #notice(remote_details)
      remote_props = JSON.parse(remote_details)
      p = {}
      if remote_props["data"]["properties"]
        remote_props["data"]["properties"].each do |prop|
          propname = prop["name"]
          if prop["value"].include?("****") and resource[:properties].has_key?(propname)
            notice("Found password property. Verifying against LogicMonitor Servers")
            check_prop = rpc("verifyProperties", {"hostGroupId" => remote_group["id"], "propName" => propname, "propValue" => resource[:properties][propname]})
            #notice(check_prop)
            match = JSON.parse(check_prop)
            if match["data"]["match"]
              notice("Password appears unchanged")
              propval = resource[:properties][propname]
            else
              notice("Password has been changed.")
              propval = prop["value"]
            end
          else
            propval = prop["value"]
          end
          unless propname.eql?("puppet.update.on")
            p.store(propname, propval)
          end
        end
      end
      p
    end
  end

  def properties=(value)
    notice("Setting properties for host group \"#{resource[:fullpath]}\"")
    group = get_group(resource[:fullpath])
    hash = build_param_hash(resource[:fullpath], resource[:description], resource[:properties], resource[:alertenable], group["parentId"])
    hash.store("id", group["id"])
    response = rpc("updateHostGroup", hash)
    #notice(response)
  end

  #
  # Utility functions within the provider
  #

  def build_param_hash(fullpath, description, properties, alertenable, parent_id)
    path = fullpath.rpartition("/")
    hash = {"name" => URI::encode(path[2])}
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
    #notice(index)
    hash.store("propName#{index}", "puppet.update.on") 
    hash.store("propValue#{index}", URI::encode(DateTime.now().to_s))
    #p hash
    hash
  end

  def recursive_create(fullpath, description, properties, alertenable)
    path = fullpath.rpartition("/")
    parent_path = path[0]
    notice("checking for parent: #{path[2]}")
    parent_id = 1
    if parent_path.nil? or parent_path.empty?
      notice("highest level")
    else
      parent = get_group(parent_path)
      if not parent.nil?
        notice("parent group exists")
        parent_id = parent["id"]
      else
        parent_ret = recursive_create(parent_path, nil, nil, true) #create parent group with basic information.
        unless parent_ret.nil?
          parent_id = parent_ret
        end
      end
    end
    hash = build_param_hash(fullpath, description, properties, alertenable, parent_id)
    resp_json = rpc("addHostGroup", hash)
    resp = JSON.parse(resp_json)
    if resp["data"].nil?
      nil
    else
      resp["data"]["id"]
    end
  end

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
    #notice(url)
    uri = URI(url)
    begin
      http = Net::HTTP.new(uri.host, 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(req)
      return response.body
    rescue SocketError => se
      notice "There was an issue communicating with #{url}. Please make sure everything is correct and try again."
    rescue Exception => e
      notice "There was an issue."
      notice e.message
    end
    return nil
  end

end
