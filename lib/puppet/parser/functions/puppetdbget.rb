#puppetdbget.rb

module Puppet::Parser::Functions
  newfucntion(:puppetdbget, :type => :rvalue) do |args|
    require 'net/http'
    require 'open-uri'

  end
end
