#getcollectornodes.rb

module Puppet::Parser::Functions
  newfunction(:getcollectornodes, :type => :rvalue) do |args|
    Puppet::Parser::Functions.autoloader.loadall
    require 'rubygems'
    require 'json'
    require 'cgi'
    h = {}
    facts = ""
    resp = function_puppetdbget(["/resources", '["and", ["=", "type", "Class"], ["=", "title", "Logicmonitor::Collector"]]'])
    json = JSON.parse(resp)
    json.each do |node|
      n = node["certname"]
      facts = function_puppetdbget(["/facts/#{n}"])
      facts_json = JSON.parse(facts)
      if facts_json["facts"]["lm_collector_exist"].eql?("true")
        collectorid = facts_json["facts"]["lm_collector_id"]
      else
        collectorid = -1
      end
      h = h.merge({n => collectorid})
    end
    return h
  end
end
