#LogicMonitor-Puppet

Current Version: 1.0.0

LogicMonitor is a Cloud-based, full stack, IT infrastructure monitoring solution that 
allows you to manage your infrastructure monitoring from the Cloud.
LogicMonitor-Puppet is a Puppet module for automating and managing your LogicMonitor 
(SaaS based, full stack, datacenter monitoring) portal via Puppet.

##LogicMonitor's Puppet module overview
LogicMonitor's Puppet module defines 5 classes and 4 custom resource types. For additional documentation visit http://help.logicmonitor.com/integrations/puppet-integration/

Classes:
* logicmonitor: Handles setting credentials needed for interacting with the LogicMonitor API.
* logicmonitor::config: Provides the default credentials to the logicmonitor class.
* logicmonitor::master: Collects the exported lm_host resources and lm_hostgroup resources. Communicates with the LogicMonitor API
* logicmonitor::collector: Handles LogicMonitor collector management for the device. Declares an instance of lm_collector and lm_installer resources.
* logicmonitor::host: Declares an exported lm_host resource.

Resource Types:
* lm_hostgroup: Defines the behavior of the handling of LogicMonitor host groups. Recommend using exported resources.
* lm_host: Defines the handling behavior of LogicMonitor hosts. Used only within logicmonitor::host class.
* lm_collector: Defines the handling behavior of LogicMonitor collectors. Used only with logicmonitor::collector class.
* lm_installer: Defines the handling behavior of LogicMonitor collector installation binaries. Used only within logicmonitor::collector class.

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

** Ruby (1.8.7 or 1.9.3) and Puppet 3.X **

This is a module written for Puppet 3

** Ruby Gems  JSON Gem **

This module interacts with LogicMonitor's API which is JSON based. JSON gem needed to parse responses from the servers

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

Modify the "manifests/config.pp" file with your LogicMonitor account information
    class logicmonitor::config {
      # LogicMonitor API access credentials
      # your account name is take from the web address of your account, 
      # eg "https://chipmco.logicmonitor.com"
      $account  = 'chimpco'
      $user     = 'bruce.wayne'
      $password = 'nanananananananaBatman!'
    }

### Logicmonitor::Master Node

#### Using credentials set in logicmonitor::config
# modify

    node /^puppet-master/ {
      # the puppet master is where API calls to the LogicMonitor server are sent from
      include logicmonitor::master
      
      # In our example, the master will also have a collector installed.  This is optional - the
      # collector can be installed anywhere
      include logicmonitor::collector  

      class {'logicmonitor::host':
        collector => $fqdn,
        groups => ["/puppet", "/puppetlabs/puppetdb"],
        properties => {"test.prop" => "test2", "test.port" => 12345 },
      }

      # Managing the properties on the root host group will set these properties for the entire LogicMonitor account
      # These properties can be over written by setting them at the child group or host level.
      @@lm_hostgroup { "/":
        properties => {"mysql.user" => "default_user" },
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

         # Managing the properties on the root host group will set these properties for the entire LogicMonitor account
         # These properties can be over written by setting them at the child group or host level.
    	 @@lm_hostgroup { "/":
    	       properties => {"mysql.user" => "default_user" },
    	 }

    	 @@lm_hostgroup { "/puppet":
    	       properties => {"mysql.port"=>1234, "snmp.community"=>"puppetlabs" },
    	       description => 'This is a group with all puppet managed hosts',
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
