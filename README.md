#LogicMonitor-Puppet

LogicMonitor-Puppet is a Puppet module for automating and managing your LogicMonitor 
(SaaS based, full stack, datacenter monitoring) portal via Puppet.

So far, we've implemented the following features:

* Collector Management
  * Creation of new collector
  * Download of collector install package
  * Installation of collector
* Host Management
  * Addition of hosts to LogicMonitor portal.
  * Host level settings:
    * Host name/IP address
    * Display Name
    * Host groups
    * Properties (e.g. MySQL port, SNMP Community, etc.)
    * Description
    * Alerting Enabled/Disabled
* Host Group Management
  * Addition of multiple levels of host groups to LogicMonitor portal
  * Host group level settings
    * Group name
    * Properties (e.g. MySQL port, SNMP Community, etc.)
    * Description
    * Alerting Enabled/Disabled

Upcoming features:

* Host management
  * Host update and overwrite modes
    * Update keeps changes made in the UI and adds updates from Puppet
    * Overwrite removes everything that is not under puppet control
* Host group management
  * Host group update and overwrite modes
    * Update keeps changes made in the UI and adds updates from Puppet
    * Overwrite removes everything that is not under puppet control
* User management
  * Add and remove users
  * Assign user roles

## Requirements

** PuppetDB **

This module makes extensive use of PuppetDB's REST API to gather information about the 
hosts and groups to manage through puppet. Currently, communication to PuppetDB is 
supported through HTTP only. Because of this, we recommend making the PuppetDB listen for 
HTTP connections on localhost and instantiate the logicmonitor::master class on the same
node as the running PuppetDB instance.

** Ruby Gems/JSON gem **

PuppetDB and LogicMonitor each use a JSON format REST API. Due to Puppet working best with 
Ruby 1.8.7 we require Ruby Gems and the JSON gem.

## Installation

### Using the Module Tool

    $ puppet module install logicmonitor-logicmonitor

### Installing via GitHub

    $ cd /etc/puppet/modules
    $ git clone git://github.com/logicmonitor/logicmonitor-puppet.git
    $ mv logicmonitor-puppet logicmonitor

## Examples

### Logicmonitor::Master Node

node /^puppet-node1/ {

  include logicmonitor::master
  include logicmonitor::collector  
  class {'logicmonitor::host':
    collector => $fqdn,
    groups => ["/puppet", "/puppetlabs/puppetdb"],
    properties => {"snmp.version" => "v2c"},
  }

  logicmonitor_group { "/puppet":
    properties => {"mysql.port"=>1234, "snmp.community"=>"puppetlabs" },
    description => 'This is the top level puppet managed host group',
  }

  logicmonitor_group {"/puppetlabs":}

  logicmonitor_group { "/puppetlabs/puppetdb":
    properties => {"snmp.community"=>"public"},
  }

}


### Logicmonitor::Host Node

node /^puppet-node2/ {
  class {'logicmonitor::host': 
    collector => 9,
    ip_address => "10.171.117.9",
    groups => ["/puppet", "/", "/puppetlabs/something/somethingelse"],
    properties => {"snmp.community" => "puppetlabs"},
  }
}


### Logicmonitor::Collector Node

node /^puppet-node3/ {
  include logicmonitor::collector
}
