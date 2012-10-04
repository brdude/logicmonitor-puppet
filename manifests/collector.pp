# === Class: logicmonitor::collector
#
# Manages the creation, download and installation of a LogicMonitor collector on the specified node. 
#
# === Parameters
#
# This class has no parameters
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

class logicmonitor::collector inherits logicmonitor {

  
  if $lm_collector_exist != 'true' {
    $collectorID = newcollector()
    exec { "/usr/bin/ruby collectordownloader.rb ${Logicmonitor::portal} ${Logicmonitor::user} ${Logicmonitor::password} ${collectorID}": 
      cwd     => "/usr/local/logicmonitor",
      creates => "/usr/local/logicmonitor/agent/conf/agent.conf",
      require => File['/usr/local/logicmonitor/collectordownloader.rb'],
    }
    
  }  
  
  
  file { '/usr/local/logicmonitor/collectordownloader.rb':
    ensure  => file,
    mode    => '0755',
    source  => 'puppet:///modules/logicmonitor/collectordownloader.rb',
    require => File["/usr/local/logicmonitor/"],
  }
  
  file { '/usr/local/logicmonitor/':
    ensure => directory,
    mode   => '0777',
  }
}
