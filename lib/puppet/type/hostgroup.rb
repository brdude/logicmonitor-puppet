# === Define: logicmonitor_group
#
# This resource type defines a host group in a LogicMonitor Portal. There is no associated provider for this type.
# Instead, the purpose is to introduce the following information into a puppetDB catalog for use by the LogicMonitor Master node.
#
# === Parameters
#
# [*namevar*]
#    Or "fullpath" 
#    Sets the path of the group. Path must start with a "/"
#
# [*description*]
#    Set the description shown in the LogicMonitor portal
#
# [*properties*]
#    Must be a Hash object of property names and associated values.
#    Set custom properties at the group level in the LogicMonitor Portal
#
# [*alertenable*]
#    Boolean value setting whether to deliver alerts on hosts within this group.
#    Overrides host level alert enable setting
#
# [*mode*]
#    Set the puppet management mode.
#    add - only add groups which are not already in the LogicMonitor portal
#    update - will add properties to existing groups or create groups which do not exist. Will not delete anything.
#    overwrite - will replace all group with only information contained in puppet.
#
# === Examples
#
# logicmonitor_group { "/puppet":
#   properties => {"mysql.port"=>1234, "snmp.community"=>"puppetlabs" },
#     description => 'This is the top level puppet managed host group',
# }
#
# logicmonitor_group {"/puppetlabs":}
#
# logicmonitor_group { "/puppetlabs/puppet":
#   alertenable => false,
#   description => "A very useful description",
# }
#
# === Authors
# 
# Ethan Culler-Mayeno <ethan.culler-mayeno@logicmonitor.com>
#
# === Copyright
#
# Copyright 2012 LogicMonitor, Inc
#

Puppet::Type.newtype(:hostgroup) do
  @doc = "Create a new host group in LogicMonitor Portal "

#  newparam(:fullpath, :namevar => true) do
#    desc "The full path including all parent groups. Format: \"/parentgroup/childgroup\""
#    validate do |value|
#      unless value.start_with?("/") == true
#        raise ArgumentError, "#{value} is not a valid path"
#      end
#    end
#  end

#  newparam(:description) do
#    desc "The long text description of a host group"
#    
#  end
  
#  newparam(:properties) do
#    desc "A hash where the keys represent the property names and the values represent the property values. (e.g. {\"snmp.version\" => \"v2c\", \"snmp.community\" => \"public\"})"
#    validate do |value|
#      unless value.class == Hash
#        raise ArgumentError, "#{value} is not a valid set of group properties. Properties must be in the format {\"propName0\"=>\"propValue0\",\"propName1\"=>\"propValue1\", ... }"
#      end
#    end
#  end
  
#  newparam(:alertenable) do
#    desc "Set alerting at the host group level. A value of false will turn off alerting for all hosts and subgroups in that group."
#    newvalues(:true, :false)
#  end
  
  # Currently an inactive flag.
#  newparam(:mode) do
#    desc "Allow the group to be add-only (only modifies the portal if the group does not exist), update (existing properties and location of the group are unaffected, append new properties), or overwrite (puppet control only)"
#    newvalues(:add, :update, :overwrite)
#  end
  
end
