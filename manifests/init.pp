# == Class: mysensors
#
# This class installs the MySensors Raspberry Pi Gateway
# The code is checked out from https://github.com/mysensors/Raspberry
#
# === Parameters
#
# Document parameters here.
#
# [*install_mqttgw*]
#   Installs the MQTT Gateway as well. If the variable is set to false it'll
#   just install the SerialGateway
#
# [*manage_git*]
#   Includes the puppetlabs git module since puppetlabs-vcsrepo needs it
#
# === Variables
#
#
# === Examples
#
#  class { 'mysensors': }
#
# === Authors
#
# Hannes Schaller <admin@cyberkov.at>
#
# === Copyright
#
# Copyright 2015 Hannes Schaller, unless otherwise noted.
#
class mysensors (
  $install_mqttgw = true,
  $manage_git     = true
) {

  if $::osfamily != 'Debian' or $::architecture != 'armv7l' {
    fail("This class is designed for Raspbian/Debian on Arm Architecture.
    OS reported as ${::osfamily} on ${::architecture}. Sorry.")
  }

  # Set defaults for exec resource
  Exec {
    path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  }

  ensure_packages('build-essential')

  if $manage_git { class {'git': before => Vcsrepo['/opt/mysensors_rpi'] } }

  vcsrepo { '/opt/mysensors_rpi':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/mysensors/Raspberry.git',
    notify   => Exec['librf24-bcm-make-all'],
  }

  exec { 'librf24-bcm-make-all':
    command     => 'make all',
    cwd         => '/opt/mysensors_rpi/librf24-bcm',
    refreshonly => true,
    notify      => Exec['librf24-bcm-make-install'],
  }
  exec { 'librf24-bcm-make-install':
    command     => 'make install',
    cwd         => '/opt/mysensors_rpi/librf24-bcm',
    refreshonly => true,
    notify      => Exec['mysensors-make-all'],
  }

  exec { 'mysensors-make-all':
    command => 'make all',
    cwd     => '/opt/mysensors_rpi',
    notify  => Exec['mysensors-make-install'],
    creates => '/opt/mysensors_rpi/PiGatewaySerial',
  }
  exec { 'mysensors-make-install':
    command => 'make install',
    cwd     => '/opt/mysensors_rpi',
    creates => '/etc/init.d/PiGatewaySerial',
  }

  service { 'PiGatewaySerial':
    ensure  => 'running',
    enable  => true,
    require => Exec['mysensors-make-install'],
  }

  if $install_mqttgw {
    class { '::mysensors::mqttgw': }
  }


}
