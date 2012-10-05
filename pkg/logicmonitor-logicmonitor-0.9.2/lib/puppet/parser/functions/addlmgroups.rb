#addlmgroups.rb
#Arguments:  TBA
#Returns:  TBA

module Puppet::Parser::Functions
  newfunction(:addlmgroups, :type => :rvalue) do |args|
    Puppet::Parser::Functions.autoloader.loadall
    require 'rubygems'
    require 'json'
    require 'cgi'

    rval = ""

    def addgroup( portalGroups, managedGroups, fullpath, parameters)
      portal = lookupvar('Logicmonitor::portal')
      user = lookupvar('Logicmonitor::user')
      password = lookupvar('Logicmonitor::password')
      path = fullpath.split('/')
      parent = fullpath.chomp("/#{path[-1]}")
      
      if parent.empty?
        addstr = addstring(path[-1], parameters)
        resp = function_apiget([portal, user, password, addstr])
        json = JSON.parse(resp)
        if json["status"] == 200
          added_groups = {fullpath => json["data"]["id"]}
          rval << "Addition of group " + fullpath + " succeeded\n"
          return added_groups
        else
          rval << "Addition of group " + fullpath + " failed. " + json["errmsg"] + "\n"
          return {}
        end
      elsif portalGroups[parent] != nil
        #add
        parent_id = portalGroups[parent]
        addstr = addstring(path[-1], parameters)
        resp = function_apiget([portal, user, password, addstr + "&parentId=" + parent_id.to_s])
        json = JSON.parse(resp)
        if json["status"] == 200
          added_groups = {fullpath => json["data"]["id"]}
          rval << "Addition of group " + fullpath + " succeeded\n"
          return added_groups
        else
          rval << "Addition of group " + fullpath + " failed. " + json["errmsg"] + "\n"
          return {}
        end
      elsif portalGroups.has_key?(parent) == false and managedGroups.has_key?(parent) == true
        #recurse
        added_groups = {}
        added_groups = added_groups.merge(addgroup(portalGroups, managedGroups, parent, managedGroups[parent]))
        newPortalGroups = portalGroups.merge(added_groups)
        added_groups = added_groups.merge(addgroup(newPortalGroups, managedGroups, fullpath, parameters))
        return added_groups
      else
        #error
        rval << "Addition of group " + fullpath + " failed. Required parent group " + parent + " does not exist and is not under puppet management.\n"
        return {}
      end
      return "test"
    end


    def addstring(name, params)
      addString = "/rpc/addHostGroup?name=" + name
      p = params
      if p.empty?
        addString << "&alertEnable=true"
      else
        if p.has_key?("alertenable")
          addString << "&alertEnable=" + p["alertenable"]
        else
          addString << "&alertEnable=true"
        end

        if p.has_key?("description")
          addString << "&description=" + CGI::escape(p["description"])
        end

        if p.has_key?("properties") && p["properties"].empty? == false
          i = 0
          p["properties"].each_pair do |key, value|
            addString << "&propName" + i.to_s + "=" + key + "&propValue" + i.to_s + "=" + value
            i = i + 1
          end
        end
      end
      return addString 
    end


    existing_groups = function_getlmgroups()
    puppet_groups = JSON.parse(function_puppetdbget("/resources", '["=", "type", "Logicmonitor_group"]'))

    groups = {}
    puppet_groups.each do |group|
      if group["title"].eql?("/") == false
        groups = groups.merge({group["title"] => group["parameters"]})
      end
    end

    groups.each_pair do |key, value|
      if existing_groups.has_key?(key) == false
        resp = addgroup(existing_groups, groups, key, value)
        rval << resp.to_s + "\n"
      end
    end

    return rval 
    
  end
end
