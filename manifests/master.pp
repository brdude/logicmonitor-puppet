#master.pp
# This is a required non-idempotent class (There needs to be one and only one node with this class declared)
# The node with this class will handle the host and group management for the entire LogicMonitor Portal similar to Cisco and F5's proxies.


class logicmonitor::master inherits logicmonitor {

      $test = addlmhosts()

      notify{ 'Hosts2':
            message => $test,
      }
} 

