#collector

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
