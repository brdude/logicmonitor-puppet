# LogicMonitor top-level group
# 

#class logicmonitor{
#      $portal = "ethandev"
#      $user = "ethan"
#      $password = "ethanD3v"
#}

class logicmonitor{
      $portal = "demo"
      $user = "ethan"
      $password = "3th4nd3v"
      
      #Current solution for this module knowing how to speak to puppetdb: have the user set the hostname and port for the HTTP communication

      $puppetdb_host = 'puppet.logicmonitor.net'
      $puppetdb_http_port = 8080

}
