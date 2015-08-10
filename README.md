#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with logicmonitor](#setup)
    * [What logicmonitor affects](#what-logicmonitor-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with logicmonitor](#beginning-with-logicmonitor)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

LogicMonitor is a Cloud-based, full stack, IT infrastructure monitoring solution that 
allows you to manage your infrastructure monitoring from the Cloud.

## Module Description

LogicMonitor-Puppet is a Puppet module for automating and managing your LogicMonitor 
(SaaS based, full stack, datacenter monitoring) portal via Puppet.

## Setup

### What logicmonitor affects

* Creates the directory '/usr/local/logicmonitor/' where it places all its binary files.
* Services
	* logicmonitor-agent
	* logicmonitor-watchdog
* Can create/delete logicMonitor collectors.
* Can create/delete/modify host groups and sub-groups.
	* Properties for a puppet managed group that are manually entered or modified will get errased/overriden.
* Can create/delete/modify hosts.
	* Properties for a puppet managed host that are manually entered or modified will get errased/overriden.

### Setup Requirements

* Ruby (1.8.7 or 1.9.3) and Puppet 3.X - This is a module written for Puppet 3
* Ruby Gems  JSON Gem - This module interacts with LogicMonitor's API which is JSON based. JSON gem needed to parse responses from the servers
* storeconfigs - This module uses exported resources extensively. Exported resources require storeconfigs = true.

### Beginning with logicmonitor

Installing a logicMonitor collector:

```puppet
class { '::logicmonitor':
  account  => "myCompany",
  user     => "myUserName",
  password => "myPassword",
}
```

## Usage

### Installing a LogicMonitor collector

```puppet
node "logicmonitor-collector.example.local" {
  class { '::logicmonitor':
    account  => "myCompany",
    user     => "myUserName",
    password => "myPassword",
  }
}
```

NOTE:  The collector will be identied by the facter derived FQDN, eg
       "logicmonitor-collector.example.local" in this case.

### Installing a LogicMonitor collector with Hiera

```puppet
node "logicmonitor-collector.example.local" {
  class { '::logicmonitor': }
}
```

```yaml
---
logicmonitor::account  : myCompany
logicmonitor::user     : myUserName
logicmonitor::password : myPassword
```

NOTE:  The collector will be identied by the facter derived FQDN, eg
       "logicmonitor-collector.example.local" in this case.
       
### Installing a LogicMonitor Master

The puppet master is where API calls to the LogicMonitor server are sent from.
  
In this example, the master will also have a collector installed.  This is optional,
the collector can be installed anywhere.

```puppet
node "logicmonitor-master.example.local" {
  include logicmonitor::master
  class { '::logicmonitor': }
}
```

### Creating a host group

```puppet
node "server.example.local" {
  lm_hostgroup { "/":
    account    => "myCompany",
    user       => "myUserName",
    password   => "myPassword",
    properties => {
      "snmp.community"  => "public",
      "tomcat.jmxports" => "9000",
      "mysql.user"      => "monitoring",
      "mysql.pass"      => "MyMysqlPW"
    },
  }
}
```

### Creating a host group using a LogicMonitor Master and Exported Resources (storeconfigs)

```puppet
node "logicmonitor-master.example.local" {
  include logicmonitor::master
  class { '::logicmonitor': }
}


node "server.example.local" {

# Managing the properties on the root host group ("/") will set the properties for the entire 
# LogicMonitor account.  These properties can be over-written by setting them on a child 
# group, or on an individual host.
  @@lm_hostgroup { "/":
    properties => {
      "snmp.community"  => "public",
      "tomcat.jmxports" => "9000",
      "mysql.user"      => "monitoring",
      "mysql.pass"      => "MyMysqlPW"
    },
  }
  
# create "Development" and "Operations" hostgroups
  @@lm_hostgroup {"/Development":
    description => 'This is the top level puppet managed host group',
  }

  @@lm_hostgroup {"/Operations":}

# Create US-West host group, as well as a sub-group "production".  
# The "production" group will have use a different SNMP community
  @@lm_hostgroup {"/US-West":}
  @@lm_hostgroup {"/US-West/production":
    properties => { "snmp.community"=>"secret_community_RO" },
  }

  @@lm_hostgroup {"/US-East":}
}
```

### Creating a host group using Hiera

```puppet
node "logicmonitor-collector.example.local" {
  class { '::logicmonitor': }
  include ::logicmonitor::hostgroups
}
```

```yaml
---
logicmonitor::account  : myCompany
logicmonitor::user     : myUserName
logicmonitor::password : myPassword

logicmonitor::hostgroups::groups:
  /:
    properties:
      snmp.community  : public
      tomcat.jmxports : 9000
      mysql.user      : monitoring
      mysql.pass      : MyMysqlPW
  /Development:
    properties:
    description: 'This is the top level puppet managed host group'
  /Operations:
    properties:
  /US-West:
    properties:
  /US-West/production:
    properties:
      snmp.community  : secret_community_RO
  /US-East:
    properties:
```

### Add a host to be monitored

```puppet
node "server.example.local" {
  class {'logicmonitor::host':
    collector  => "logicmonitor-master.example.local",
    groups     => ["/Operations", "/US-West"],
    properties => {"test.prop" => "test2", "test.port" => 12345 },
  }
}
```

## Reference

### Classes

#### Public Classes

* logicmonitor: Creates a LogicMonitor collector
* logicmonitor::master: Collects the exported lm_host resources and lm_hostgroup resources. Communicates with the LogicMonitor API
* logicmonitor::host: Declares an exported lm_host resource.
* logicmonitor::hostgroups: Allows you to create host groups and set their parameters through Hiera. 

#### Private Classes

* logicmonitor::install: Calls lm_collector and lm_installer to create a new collector and install the required files.
* logicmonitor::service: Ensures the required services for LogicMonitor are running and are set to start on boot.
* logicmonitor::params: Contains the variables with the default LogicMonitor parameters.

### Parameters

#### logicmonitor
 
#####`account`
  The name of your account for LogicMonitor. Your account name 
  is take from the web address of your account, 
  eg "https://account.logicmonitor.com"

#####`user`
  LogicMonitor username.

#####`password`
  LogicMonitor password for the respective username.

#####`install_dir`
  The location where the LogicMonitor files are installed.

#####`agent_service`


#####`watchdog_service`

#### logicmonitor::master

#### logicmonitor::host

#####`collector`
  Required
  Sets which collector will be handling the data for this device.
  Accepts a fully qualified domain name. A collector with the
  associated fully qualified domain name must exist in the
  Settings -> Collectors tab of the LogicMonitor Portal.

#####`hostname`
  Defaults to the fully qualified domain
  name of the node.
  Provides the default host name and display name
  values for the LogicMonitor portal
  Can be overwritten by the $display_name and
  $ip_address parameters

#####`displayname`
  Defaults to the value of $host_name.
  Set the display name that this node will appear
  within the LogicMonitor portal

#####`description`
  Defaults to "UNSET"
  Set the host description shown in the LogicMonitor Portal

#####`alertenable`
  Defaults to true
  Set whether alerts will be sent for the host.
  Note: If a parent group is set to alertenable=false
  alerts for child hosts will be turned off as well.

#####`groups`
  Must be an Array of group names.
  e.g. groups => ["/puppetlabs", "/puppetlabs/puppetdb"]
  Default to empty.
  Set the list of groups this host belongs to.
  If left empty will add at the global level.
  To add to a subgroup, the full path name must be specified.

#####`properties`
  Must be a Hash of property names and associated values.
  e.g. {"mysql.user" => "youthere", "mysql.port" => 1234}
  Default to empty
  Set custom properties at the host level

#####`opsnote`
  Boolean. Defaults to false.
  When true will insert an OpsNote in your
  LogicMonitor account when Puppet updates the host.

#### logicmonitor::hostgroups

#####`groups`
  A hash of the hostgroups and it's properties to be created.

#####`ensure`
  The state that puppet should ensure the host group is in.

##Limitations

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

