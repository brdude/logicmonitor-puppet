# === Class: Logicmonitor
#
# This is the top level class for managing your LogicMonitor portal through Puppet and PuppetDB.
# It also is the location where you specify the required credentials for both your LogicMonitor portal as well as configure access to a running PuppetDB.
#
# === Parameters
#
# [*account*]
#    Sets which portal to manage
#
# [*user*]
#    Username for access to the portal. This user must have sufficient permissions to create/modify hosts, host groups, and collectors
#
# [*password*]
#    Password for access to the portal
#
# [*puppetdb_server*]
#    Hostname on which the PuppetDB server is listening for HTTP traffic. Recommend using localhost.
#
# [*puppetdb_http_port*]
#    Port on which the PuppetDB server is listening for HTTP traffic.
#
# NOTE: all parameters can be set when the class is declared in your site.pp (must be declared either globally or on a single node)
#   or in the variables found in logicmonitor::config
#
# === Variables
#
#  TBD
#
# === Examples
#
# With parameters:
#   class{ "logicmonitor":
#     account             => "mycompany",
#     $user               => "me",
#     $password           => "password",
#     $puppetdb_server    => "localhost",
#     $puppetdb_http_port => 8080,
#   }
#
# Using logicmonitor::config:
#   class( "logicmonitor": }
#
# === Authors
#
# Ethan Culler-Mayeno <ethan.culler-mayeno@logicmonitor.com>
#
# === Copyright
#
# Copyright 2012 LogicMonitor, Inc
#

class logicmonitor(
  $account=$logicmonitor::config::account, 
  $user=$logicmonitor::config::user, 
  $password=$logicmonitor::config::password, 
  $puppetdb_server=$logicmonitor::config::puppetdb_server, 
  $puppetdb_http_port=$logicmonitor::config::puppetdb_http_port) inherits logicmonitor::config {
  
    notify{"logicmonitor credentials initiated": }

  }
