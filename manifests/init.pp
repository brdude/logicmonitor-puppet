# === Class: Logicmonitor
#
# This is the top level class for managing your
# LogicMonitor portal through Puppet and PuppetDB.
# It also is the location where you specify the
# required credentials for both your LogicMonitor
# portal as well as configure access to a running PuppetDB.
#
# === Parameters
#
# - LogicMonitor API access credentials.
#
# [account]
#    The name of your LogicMonitor account.
#    E.g. companyname.logicmonitor.com's account should be "companyname"
#
# [user]
#    A username with adaquate credentials to create,
#    modify, and delete hosts, host groups, and collectors
#    We recommend creating a puppet only user to track changes
#    made by Puppet in the audit log.
#
# [password]
#    The password associated with the chose LogicMonitor user.
#
# === Examples
#
# With parameters:
#   class{ 'logicmonitor':
#     account             => 'mycompany',
#     $user               => 'me',
#     $password           => 'password',
#   }
#
# Using Hiera
#   class{ 'logicmonitor': }
#
# === Authors
#
# Ethan Culler-Mayeno <ethan.culler-mayeno@logicmonitor.com>
#
# === Copyright
#
# Copyright 2012 LogicMonitor, Inc
#
class logicmonitor (
  $account          = $::logicmonitor::params::account,
  $user             = $::logicmonitor::params::user,
  $password         = $::logicmonitor::params::password,
  $install_dir      = $::logicmonitor::params::install_dir,
  $agent_service    = $::logicmonitor::params::agent_service,
  $watchdog_service = $::logicmonitor::params::watchdog_service,
) inherits ::logicmonitor::params {

  # validate parameters here
  validate_string($account)
  validate_string($user)
  validate_string($password)
  validate_absolute_path($install_dir)
  validate_string($agent_service)
  validate_string($watchdog_service)

  contain logicmonitor::install
  contain logicmonitor::service
}
