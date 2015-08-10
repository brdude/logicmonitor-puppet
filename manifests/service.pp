# == Class logicmonitor::service
#
# This class is meant to be called from logicmonitor.
# It ensure the service is running.
#
class logicmonitor::service {

  service { $::logicmonitor::agent_service:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Lm_installer[$::fqdn],
  }
  
  service { $::logicmonitor::watchdog_service:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Lm_installer[$::fqdn],
  }
  
}
