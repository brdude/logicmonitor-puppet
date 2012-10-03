#host

class logicmonitor::host(
  $collector,
  $host_name    = $fqdn,
  $display_name = "UNSET",
  $ip_address   = "UNSET",
  $description  = "UNSET",
  $groups       = [],
  $properties   = {},
  ) inherits logicmonitor {

}
