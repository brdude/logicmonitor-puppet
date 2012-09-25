#getcollectornodes.rb

module Puppet::Parser::Functions
  newfunction(:getcollectornodes, :type => :rvalue) do |args|
    Puppet::Parser::Functions.autoloader.loadall
    require 'json'
    require 'cgi'
    array = []
    request = 'resources?query=' + CGI::escape('["and", ["=", "type", "Class"],  ["=", "title", "Logicmonitor::Collector"]]')
    resp = function_puppetdbget([request])
    json = JSON.parse(resp)
    json.each do |node|
      n = node["certname"]
      facts = function_puppetdbget(["facts/#{n}"])
      facts_json = JSON.parse(facts)
      collectorid = facts_json["facts"]["collectorid"]
      arary = array.push([n, collectorid])
    end
    collectorLookup = Hash[array]
    return collectorLookup
  end
end    
