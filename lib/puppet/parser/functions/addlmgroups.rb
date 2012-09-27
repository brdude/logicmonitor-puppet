#addlmgroups.rb

module Puppet::Parser::Functions
  newfunction(:addlmgroups, :type => :rvalue) do |args|
    Puppet::Parser::Functions.autoloader.loadall
    require 'json'
    require 'cgi'
    portal = lookupvar('Logicmonitor::portal')
    user = lookupvar('Logicmonitor::user')
    password = lookupvar('Logicmonitor::password')
    returnVal = []
    lmGroups = function_gethostgroups([])
    addgroupquery = ""
    groupsrequest = 'resources?query=' + CGI::escape('["=", "type", "Logicmonitorhostgroup"]')
    getgroups = function_puppetdbget([groupsrequest])
    groups_json = JSON.parse(getgroups)
    groupLookup = []
    #populate the full list of the requested groups
    groups_json.each do |group|
      fullpath = function_getpath(group["parameters"]["fullpath"])
      groupsLookup = groupsLookup.push(fullpath)
    end
    
    #begin group management
    groups_json.each do |group|
      fullpath = function_getpath(group["parameters"]["fullpath"])
      path = fullpath.split('/')
      parentPath = fullpath.chomp("/#{path[-1]}")
      if lmGroups[fullpath] == nil
        if parentPath.empty? == false
          if groupLookup.include?(parentPath) == false
            raise Puppet::ParseError, "Group #{fullpath} could not be added. Parent group #{parentPath} was not found."
          end #if groupLookup.include
        end #if fullpath.include
        
        addgroupquery << "/rpc/addHostGroup?"
        addgroupquery << "Name=#{path[-1]}"
        if description.include?("UNSET") == false
          addgroupquery = addgroupquery + "&description=#{CGI::escape(description)}"
        end #end if
        addgroupquery << "&alertEnable=#{alertEnable}"
        i = 0
        propsHash = group["parameters"]["properties"]
        propsHash.each_pair do |key, value|
          addgroupquery = addgroupquery + "&propName#{i}=#{key}&propValue#{i}=#{value}"
          i = i + 1
        end #end propHash.each
        
        if parentPath.empty?
          addgroupquery = addgroupquery + "&parentId=1"
        else
          parentId = lmGroups[parentPath]
          addgroupquery = addgroupquery + "&parentId=#{parentId}"
        end
        
      end #if lmGroups[fullpath]
    end #groups_json.each
    return returnval
  end #newfunction
end #module