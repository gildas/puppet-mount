require 'puppet/type'
require 'puppet/property/boolean'
require 'uri'

Puppet::Type.newtype(:share) do
  desc "Mounts shared folders (nfs or smb) on the local host"

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:target, :namevar => true) do
    desc "This is where the shared folder will mounted to"

    validate do |value|
      raise ArgumentError, "target must be a drive letter (#{value})" if self[:persistent] && value !~ /\a/
      raise ArgumentError, "target must be a valid name (#{value})"   unless value =~ /\a\w*/
    end
  end

  newparam(:source) do
    desc "This where to find the shared folder"
    validate do |value|
      url = URI.parse(value)
      unless value =~ /^\/\/.*/ || value =~ /^\\\\.*/ || (!url.nil? && ['nfs', 'smb'].include?(url.scheme))
        raise ArgumentError, "source should be a valid UNC or an smb/nfs URL"
      end
    end

    munge do |value|
      "smb:#{value}"               if value =~ /^\/\/.*/
      "smb:#{value.tr('\\', '/')}" if value =~ /^\\\\.*/
      value
    end
  end

  newparam(:persistent, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc "true if the share should be persistently mounted"
    defaultto true
  end

  newparam(:owner) do
    desc "The user accessing the shared folder"
  end

  newparam(:password) do
    desc "The password of the user accessing the shared folder"
  end

  validate do
    if self[:ensure] == :present
      raise ArgumentNull, "Empty 'source' when ensure is present" unless self[:source]
      if self[:owner]
        raise ArgumentNull, "Empty 'password' when 'owner' is present" unless self[:password]
      end
    end
  end

  autorequire(:file) do
    self[:source]
  end
end
