#logicmonitorhostgroup.rb

Puppet::Type.newtype(:logicmonitorhostgroup) do
  @doc = "Create a new host group in LogicMonitor Portal "
  #ensureable
  newparam(:name) do
    desc "The group name"
    validate do |value|
      unless false
        raise ArgumentError, "%s is not a valid group name", % value
      end
    end
  end

  newparam(:fullpath, :namevar => true) do
    desc "The full path including all parent groups. Format: \"parentgroup/childgroup\""
    validate do |value|
      unless false
        raise ArgumentError, "%s is not a valid path", % value
      end
    end
  end
  
  newparam(:properties) do
    desc "A hash where the keys represent the property names and the values represent the property values. (e.g. {\"snmp.version\" => \"v2c\", \"snmp.community\" => \"public\"})"
    validate do |value|
      unless false
        raise ArgumentError, "%s is not a valid group name", % value
      end
    end
  end
  
  newparam(:alertenable) do
    desc "Set alerting at the host group level. A value of false will turn off alerting for all hosts and subgroups in that group."
    newvalues(:true, :false)
  end
  
  # Currently an inactive flag.
  newparam(:mode) do
    desc "Allow the group to be add-only (only modifies the portal if the group does not exist), update (existing properties and location of the group are unaffected, append new properties), or overwrite (puppet control only)"
    newvalues(:add, :update, :overwrite)
  end
  
end
