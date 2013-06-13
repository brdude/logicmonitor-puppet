#
#
#
#
#
#
# Author: Ethan Culler-Mayeno
#
#



Puppet::Type.newtype(:collector) do
  @doc = "allows more graceful management of LogicMonitor collectors"
 
  ensurable
  
  newparam(:description, :namevar => true) do
    desc "This is the name property. This is the collector description. Should be unique and tied to the host"
  end

  newparam(:osfam) do
    desc "The operating system of the system to run a collector. Supported Distros: Debian, Redhat, and Amazon. Coming soon: Windows "
    valid_list = ["redhat", "debian", "amazon"]
    validate do |value|
      unless valid_list.include?(value.downcase())
        raise ArgumentError, "%s is not a valid distribution for a collector. Please install on a Debian, Redhat, or Amazon operating system" % value
      end
    end
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
