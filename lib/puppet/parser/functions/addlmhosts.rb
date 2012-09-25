#addlmhosts.rb

module Puppet::Parser::Functions
  newfunction(:addlmhosts, :type => :rvalue) do |args|
    Puppet::Parser::Functions.autoloader.loadall
    require 'cgi'
    require 'json'
    collectorNodes = function_getcollectornodes([])
    lmHosts = function_gethosts([])
    lmGroups = function_gethostgroups([])

    hostReq = 'resources?query=' + CGI::escape('["and", ["=", "type", "Class"],  ["=", "title", "Logicmonitor::Host"]]')
    hostnodes = function_puppetdbget([hostReq])
    host_json = JSON.parse(hostnodes)
    collector = ""
    host_json.each do |node|
      collectorid = 0
      #handle the collector id information
      collector = node["parameters"]["collector"]
      #Will not be nil if they passed the fqdn of the collector, should be nil if they passed it as a collector
      if collectorNodes["#{collector}"] != nil
        collectorid = collectorNodes[collector]
      elsif collector.to_i != 0
        collectorid = collector 
      else
        raise Puppet::ParseError, "Collector does not exist"
      end

      


    end
    true
  end
end
