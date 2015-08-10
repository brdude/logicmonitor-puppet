# == Class logicmonitor::install
#
# This class is called from logicmonitor for install.
#
# Manages the creation, download and installation of
# a LogicMonitor collector on the specified node.
#
# === Authors
#
# Ethan Culler-Mayeno <ethan.culler-mayeno@logicmonitor.com>
#
# === Copyright
#
# Copyright 2012 LogicMonitor, Inc
#
class logicmonitor::install {
  
  file { $::logicmonitor::install_dir:
    ensure => directory,
    mode   => '0755',
    before => Lm_installer[$::fqdn],
  }

  lm_collector { $::fqdn:
    ensure   => present,
    osfam    => $::osfamily,
    account  => $::logicmonitor::account,
    user     => $::logicmonitor::user,
    password => $::logicmonitor::password,
  }

  lm_installer {$::fqdn:
    ensure       => present,
    install_dir  => $::logicmonitor::install_dir,
    architecture => $::architecture,
    account      => $::logicmonitor::account,
    user         => $::logicmonitor::user,
    password     => $::logicmonitor::password,
    require      => Lm_collector[$::fqdn],
  }
}
