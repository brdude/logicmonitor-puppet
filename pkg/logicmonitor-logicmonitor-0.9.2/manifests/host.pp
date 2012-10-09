# === Class: logicmonitor::host
#
# This class flags nodes which should be added to monitoring in a LogicMonitor portal.
# In addition to flagging the node, it also sets how the node will appear in the portal
# with regards to display name, associated host groups, alerting and properties. 
#
# === Parameters
#
# [*collector*]
#    Required
#    Sets which collector will be handling the data for this device.
#    Accepts a fully qualified domain name or integer. When using a fully qualified domain name
#    to specify the collector, the node on which the collector is running must be under puppet management.
#    When using an integer to specify the collector, a collector with the associated ID number must exist
#    in the Settings -> Collectors tab of the LogicMonitor Portal.
#
# [*host_name*]
#    Defaults to the fully qualified domain name of the node.
#    Provides the default host name and display name values for the LogicMonitor portal
#    Can be overwritten by the $display_name and $ip_address parameters
#
# [*display_name*]
#    Defaults to the value of $host_name.
#    Set the display name that this node will appear under within the LogicMonitor portal
#
# [*ip_address*]
#    Defaults to the value of $host_name
#    Set the fully qualified domain name or ip address which is associated with the LogicMonitor Portal
#
# [*description*]
#    Defaults to "UNSET"
#    Set the host description shown in the LogicMonitor Portal
#
# [*alertenable*]
#    Defaults to true
#    Set whether alerts will be sent for the host.
#    Note: If a parent group is set to alertenable=false alerts for child hosts will be turned off as well.
#
# [*groups*]
#    Must be an Array of group names.
#    e.g. groups => ["/puppetlabs", "/puppetlabs/puppetdb"]
#    Default to empty.
#    Set the list of groups this host belongs to. If left empty will add at the global level. 
#    To add to a subgroup, the full path name must be specified.
#
# [*properties*]
#    Must be a Hash of property names and associated values.
#    e.g. {"snmp.version" => "v2c", "mysql.port" => 1234}
#    Default to empty
#    Set custom properties at the host level
#
# [*mode*]
#    Sets the role of puppet management.
#        "add" - will only add hosts if they do not already exist in the LogicMonitor portal.
#        "update" - will add groups and properties to existing hosts as well as add new hosts.
#        "overwrite" - will remove any properties or groups that are not specified in puppet.
#    This functionality will be available in release version 1.0
#
#  === Examples
#
#  class {'logicmonitor::host':
#          collector => 9,
#          ip_address => "10.171.117.9",
#          groups => ["/puppetlabs", "/puppetlabs/puppetdb"],
#          properties => {"snmp.community" => "puppetlabs"},
#          description => "This device hosts the puppetDB instance for this deployment",
#        }
#      
#  class {'logicmonitor::host':
#          collector => $fqdn,
#          display_name => "MySQL Production Host 1",
#          groups => ["/puppet", "/production", "/mysql"],
#          properties => {"mysql.port" => 1234},
#        }
#      
# === Authors
#
# Ethan Culler-Mayeno <ethan.culler-mayeno@logicmonitor.com
#
# === Copyright
#
# Copyright 2012 LogicMonitor, Inc
#

class logicmonitor::host(
  $collector,
  $host_name      = $fqdn,
  $display_name   = "UNSET",
  $ip_address     = "UNSET",
  $description    = "UNSET",
  $alertenable    = true,
  $groups         = [],
  $properties     = {},
  $mode = "add",
  ) inherits logicmonitor {

}