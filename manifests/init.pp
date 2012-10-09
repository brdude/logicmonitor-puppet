# === Class: Logicmonitor
#
# This is the top level class for managing your LogicMonitor portal through Puppet and PuppetDB.
# It also is the location where you specify the required credentials for both your LogicMonitor portal as well as configure access to a running PuppetDB.
#
# === Parameters
#
# This class takes no parameters. This class is used to set local variables that child classes can inherit.
#
# === Variables
#
# [*portal*]
#    Sets which portal to manage
#
# [*user*]
#    Username for access to the portal. This user must have sufficient permissions to create/modify hosts, host groups, and collectors
#
# [*password*]
#    Password for access to the portal
#
# [*puppetdb_host*]
#    Hostname on which the PuppetDB server is listening for HTTP traffic. Recommend using localhost.
#
# [*puppetdb_http_port*]
#    Port on which the PuppetDB server is listening for HTTP traffic.
#
# === Examples
#
# Primarily handled by inheritance of subclasses
#
# Explicit inclusion:
#    include logicmonitor
# 
# === Authors
#
# Ethan Culler-Mayeno <ethan.culler-mayeno@logicmonitor.com>
#
# === Copyright
#
# Copyright 2012 LogicMonitor, Inc
#

class logicmonitor {

  $portal = "YourCompanyName"
  $user = "ThisUser"
  $password = "My_Bad_Password"
  

  $puppetdb_host = "localhost"
  $puppetdb_http_port = 8080

}
