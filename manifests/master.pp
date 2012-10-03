
class logicmonitor::master inherits logicmonitor {

  notify {"Adding Host Groups":
    message => addlmgroups(),
  }

  notify {"Adding Hosts":
    message => addlmhosts(),
    require => Notify["Adding Host Groups"],
  }
  
}
