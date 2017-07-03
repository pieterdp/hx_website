require 'uri'
require 'openssl'
require 'acme-client'

Puppet::Type.newtype(:certificate) do
  @doc = 'Request an ACME certificate'
  newproperty(:endpoint) do
    desc 'ACME endpoint'
    validate do |value|
      unless value =~ URI::regexp
        raise ArgumentError, '%s is not a valid endpoint' % value
      end
    end
  end

end

#https://github.com/unixcharles/acme-client
#https://docs.puppet.com/puppet/latest/custom_types.html