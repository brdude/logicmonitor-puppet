# === Class: logicmonitor::collector
#
# Manages the creation, download and installation of a LogicMonitor collector on the specified node. 
#
# === Parameters
#
# [install_dir]
#    This is an optional parameter to chose the location to install the LogicMonitor collector
#
# === Variables
#
# [collectorID] 
#    This must be set by the newcollector function. This variable represents the ID number unique to the newly generated collector.  
#
# === Examples
#
# iclude logicmonitor::collector
#
# === Authors
#
# Ethan Culler-Mayeno <ethan.culler-mayeno@logicmonitor.com>
#
# === Copyright
#
# Copyright 2012 LogicMonitor, Inc
#

class logicmonitor::collector inherits logicmonitor($install_dir = '/usr/local/logicmonitor/'){

  file { 'install_dir':
    path => $install_dr,
    ensure => directory,
    mode   => '0755',
  }

    

  
  
}
