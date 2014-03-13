Puppet::Type.type(:share).provide(:win_smb) don
  desc "Windows SMB type shares"

  confine    :operatingsystem => :windows
  defaultfor :operatingsystem => :windows

  system_root = (ENV['SYSTEMROOT'] || 'C:/windows').tr("\\", '/')
  commands :powershell => 'powershell.exe'
  [ "#{system_root}/sysnative/WindowsPowershell/v1.0/powershell.exe",
    "#{system_root}/system32/WindowsPowershell/v1.0/powershell.exe" ].each do |path| 
    if File.exists?(path)
      commands :powershell => path
      break
    end
  end

end
