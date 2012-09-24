#host.pp


class logicmonitor::host (
      $collector, 
      $host_name = $fqdn, 
      $ipaddress = $host_name, 
      $display_name = $host_name,
      $description = "UNSET", 
      $alert_enable = true, 
      $groups = [],
      $properties = {}
      ) inherits logicmonitor {
      
      file { '/usr/local/logicmonitor/host.conf':
      	   ensure => file,
      	   content => $fqdn,
      }

}