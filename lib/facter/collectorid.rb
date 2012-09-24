#Int representing installed collector ID

Facter.add(:collectorid) do
  setcode do
    if File.exist? '/usr/local/logicmonitor/agent/conf/agent.conf'
      id = 0
      f = File.open('/usr/local/logicmonitor/agent/conf/agent.conf', 'r')
      f.each_line do |line|
        if line.include?("id=")
          id = line.match(/id=(\d+)/)[1]
        end
      end
      id
    end
  end
end
