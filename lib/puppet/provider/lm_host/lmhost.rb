# lmhost.rb
#
#
#
#
#
#
# Author: Ethan Culler-Mayeno
#
#
require 'json'
require 'open-uri'

Puppet::Type.type(:lm_host).provide(:lmhost) do
  desc "This provider handles the creation, status, and deletion of hosts in your LogicMonitor account"
  
  #
  # Functions as required by ensurable types
  #
  def create
    notice("Creating LogicMonitor host \"#{resource[:hostname]}\"")
   
  end

  def destroy
    notice("Removing LogicMonitor host  \"#{resource[:hostname]}\"")

  end

  def exists?
    notice("Checking LogicMonitor for host #{resource[:hostname]}")
    true
  end

  #
  # Display name get and set functions
  #

  #
  # Description get and set functions
  #

  #
  # Alert enable get and set functions
  #

  #
  # Alert enable get and set functions
  #

  #
  # Alert enable get and set functions
  #

  #
  # Alert enable get and set functions
  #

end
