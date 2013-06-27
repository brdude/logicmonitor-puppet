#LogicMonitor-Puppet

LogicMonitor is a Cloud-based, full stack, IT infrastructure monitoring solution that 
allows you to manage your infrastructure monitoring from the Cloud.
LogicMonitor-Puppet is a Puppet module for automating and managing your LogicMonitor 
(SaaS based, full stack, datacenter monitoring) portal via Puppet.

So far, we've implemented the following features:

* Collector Management
    
* Host Management
  * Ensurable (present/absent)
  * Managed parameters:
    * Display name
    * Description
    * Collector
    * Alerting Enabled
    * Group membership
      * Creation of groups/paths which do not yet exist
    * Properties  
* Host Group Management
  * Ensurable (present/absent)
  * Managed parameters:
    * Display name
    * Description
    * Collector
    * Alerting Enabled
    * Creation of parent groups/paths which do not yet exist
    * Properties  

Upcoming features:

* User management
  * Add and remove users
  * Assign user roles

## Requirements

** storeconfigs **

This module uses exported resources extensively. Exported resources require storeconfigs = true.

## Installation

### Using the Module Tool

    $ puppet module install logicmonitor-logicmonitor

### Installing via GitHub

    $ cd /etc/puppet/modules
    $ git clone git://github.com/logicmonitor/logicmonitor-puppet.git
    $ mv logicmonitor-puppet logicmonitor

## Examples

### Logicmonitor::Master Node

#### Using credentials set in logicmonitor::config

    node /^puppet-node1/ {
         class {"logicmonitor":}
    	 include logicmonitor::master
	 include logicmonitor::collector  


	 class {'logicmonitor::host':
	       collector => $fqdn,
	       groups => ["/puppet", "/puppetlabs/puppetdb"],
               properties => {"test.prop" => "test2", "test.port" => 12345 },
	 }

    	 @@lm_hostgroup { "/puppet":
    	       properties => {"mysql.port"=>1234, "snmp.community"=>"puppetlabs" },
    	       description => 'This is the top level puppet managed host group',
    	 }

    	 @@lm_hostgroup {"/puppetlabs":}
    	 @@lm_hostgroup { "/puppetlabs/puppetdb":
    	       properties => {"snmp.community"=>"public"},
    	 }
    }

#### Setting node specific credentials

    node /^puppet-node1/ {
         class {"logicmonitor":
	       account  => "puppet",
	       user     => "metallica",
	       password => "master_of_puppets",
	 }
    	 include logicmonitor::master
	 include logicmonitor::collector  


	 class {'logicmonitor::host':
	       collector => $fqdn,
	       groups => ["/puppet", "/puppetlabs/puppetdb"],
               properties => {"test.prop" => "test2", "test.port" => 12345 },
	 }

    	 @@lm_hostgroup { "/puppet":
    	       properties => {"mysql.port"=>1234, "snmp.community"=>"puppetlabs" },
    	       description => 'This is the top level puppet managed host group',
    	 }

    	 @@lm_hostgroup {"/puppetlabs":}
    	 @@lm_hostgroup { "/puppetlabs/puppetdb":
    	       properties => {"snmp.community"=>"public"},
    	 }
    }


### Logicmonitor::Host Node

    node /^puppet-node2/ {
         class {"logicmonitor::host":
	       collector => "puppet-node3.domain.com",
               groups => ["/test/arraytest", "/arrays", "/one/two/three" ],
  	 }


### Logicmonitor::Collector Node

    node /^puppet-node3/ {
    	 include logicmonitor::collector
    }
