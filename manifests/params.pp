# == Class logicmonitor::params
#
# This class is meant to be called from logicmonitor.
# It sets variables according to platform.
#
class logicmonitor::params {

  $account          = undef
  $user             = undef
  $password         = undef
  
  $agent_service    = 'logicmonitor-agent'
  $watchdog_service = 'logicmonitor-watchdog'
  $install_dir      = '/usr/local/logicmonitor/'

}