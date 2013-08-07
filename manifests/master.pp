# === Class: logicmonitor::master
#
# This class allows the LogicMonitor Portal management to be handled by a single host.
# We recommend having the host running puppetDB as the only instance of this class.
# Handles the host and host group management. 
#
# === Parameters
#
# This class has no paramters
#
# === Variables
#
# This class has no variables
#
# === Examples
#
# include logicmonitor::master
#
# === Authors
#
# Ethan Culler-Mayeno <ethan.culler-mayeno@logicmonitor.com>
#
# === Copyright
#
# Copyright 2012 LogicMonitor, Inc
#

class logicmonitor::master inherits logicmonitor {

  Lm_hostgroup <<| |>> {
      account  => $account,
      user     => $user,
      password => $password,
  }

  Lm_host <<| |>> {
      account  => $account,
      user     => $user,
      password => $password,
  }
}
