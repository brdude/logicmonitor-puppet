#logicmonitorhostgroup.rb

Puppet::Type.newtype(:logicmonitorhostgroup) do
  newproperty(:name) do
    validate do |value|
        unless value =~ /^\w+/
            raise ArgumentError, "%s is not a valid host group name" % value
        end
    end
    
  end
end
