#collector.pp

class logicmonitor::collector inherits logicmonitor { 
 
	 if $hascollector == false {           	 
	      $collectorID = newcollector()
#	      $collectorID = 84
	 }  


	 file { '/usr/local/logicmonitor/collectordownloader.rb':
      	      ensure  => file,
	      mode    => 755,
	      source  => 'puppet:///modules/logicmonitor/collectordownloader.rb',
	      require => File["/usr/local/logicmonitor/"],
	 }

	 file { '/usr/local/logicmonitor/':
	       ensure => directory,
	       mode   => 777,
	 }
	 

	 exec { "ruby collectordownloader.rb ${Logicmonitor::portal} ${Logicmonitor::user} ${Logicmonitor::password} ${collectorID}": 
               cwd     => "/usr/local/logicmonitor",
      	       creates => "/usr/local/logicmonitor/agent/conf/agent.conf",
      	       require => File['/usr/local/logicmonitor/collectordownloader.rb'],
         }



}