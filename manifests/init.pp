# LogicMonitor top-level group
# 


class logicmonitor{
      $portal = "puppetlabs"
      $user = "ethan"
      $password = "3thand3m0"
      
      #Current solution for this module knowing how to speak to puppetdb: have the user set the hostname and port for the HTTP communication

      $puppetdb_host = 'localhost'
      $puppetdb_http_port = 8080

}
