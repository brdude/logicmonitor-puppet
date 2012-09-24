#Boolean fact for whether a node has a LogicMonitor Collector installed

Facter.add(:hascollector) do
  setcode do
    if File.exist? '/usr/local/logicmonitor/agent/conf/agent.conf'
      true
    else
      false
    end
  end
end
