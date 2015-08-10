# == Class: logicmonitor::hostgroups
#
class logicmonitor::hostgroups (
  $groups = {},
  $ensure  = present,
) {
  
  $defaults = {
    'ensure'   => $ensure,
    'account'  => $::logicmonitor::account,
    'user'     => $::logicmonitor::user,
    'password' => $::logicmonitor::password,
  }

  validate_hash($groups)

  create_resources('lm_hostgroup', $groups, $defaults)
}