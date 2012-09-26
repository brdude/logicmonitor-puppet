#addlmgroups.rb

module Puppet::Parser::Functions
  newfunction(:addlmgroups, :type => :rvalue) do |args|
    Puppet::Parser::Functions.autoloader.loadall
    require 'json'
    require 'cgi'
    request = 'resources?query=' + CGI::escape('["=", "type", "Logicmonitorhostgroup"]')
    getgroups = function_puppetdbget([request])
    returnval = getgroups
    
    return returnval
  end
end