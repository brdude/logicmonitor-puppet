# Installer.rb
#
#
#
#
#
# Author: Ethan Culler-Mayeno
#
#


Puppet::Type.newtype(:installer) do
  @doc = "a new type to handle downloading and running the LogicMonitor collector install binary"
  ensurable
  
  newparam(:description, :namevar => true) do
    desc "This is the name property. This is the collector description. Should be unique and tied to the host"
  end

  newparam(:install_dir) do
    desc "Location to look for/place the installer"
  end

  newparam(:architecture) do
    desc "The architecture of the system. Ensures installation of optimal LogicMonitor collector"
  end

  newparam(:account) do
    desc "This is the LogicMonitor account name"
  end

  newparam(:user) do
    desc "this is the LogicMonitor Username"
  end

  newparam(:password) do
    desc "this is the password to make API calls and the LogicMonitor User provided"
  end


end
