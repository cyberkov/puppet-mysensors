# This fact has been pulled from https://github.com/redhat-cip/facter/blob/366d9d999e6e678f0f3773d13ff939cfe7a90038/lib/facter/systemd.rb
# and is used until a proper solution has been found to get the current init system
#
# Fact: systemd
#
# Purpose: 
#   Determine whether SystemD is the init system on the node
#
# Resolution:
#   Check the name of the process 1 (ps -p 1)
#
# Caveats:
#

# Fact: systemd-version
#
# Purpose: 
#   Determine the version of systemd installed
#
# Resolution:
#  Check the output of systemctl --version
#
# Caveats:
#

Facter.add(:systemd) do
  confine :kernel => :linux
  setcode do
    result = false
    init_process_name = Facter::Core::Execution.exec('ps -p 1 -o comm=')
    if init_process_name.eql? 'systemd'
      result = true
    end
  end
end

Facter.add(:systemd_version) do
  confine :systemd => true
  setcode do
    version = Facter::Core::Execution.exec("systemctl --version | grep 'systemd' | awk '{ print $2 }'")
  end
end
