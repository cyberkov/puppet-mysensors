# This class installs the mqttGateway
# and all it's required CPAN libraries through meltwater/cpan
class mysensors::mqttgw {
  $cpan_modules = [
    'IO::Socket::INET',
    'Net::MQTT::Constants',
    'AnyEvent::Socket',
    'AnyEvent::Handle',
    'AnyEvent::MQTT',
    'AnyEvent::Strict',
    'Device::SerialPort',
    'enum'
  ]

  file { '/usr/local/sbin/mqttGateway2.pl':
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/mysensors/mqttGateway2.pl',
  }

  file {'/etc/mysensors':
    ensure => 'directory',
    mode   => '0755',
    owner  => 'root',
    group  => 'root'
  }

  include cpan

  cpan { $cpan_modules:
    ensure  => present,
    require => Class['::cpan'],
  }

  if $::systemd {
    file { 'mqttGateway2.init':
      ensure  => present,
      path    => '/etc/systemd/system/mqttGateway2.service',
      content => template('mysensors/mqttGateway2.service.erb'),
      require => File['/usr/local/sbin/mqttGateway2.pl'],
    }
  } else {
    file { 'mqttGateway2.init':
      ensure  => present,
      path    => '/etc/init.d/mqttGateway2',
      mode    => '0755',
      content => template('mysensors/mqttGateway2.init.erb'),
      require => File['/usr/local/sbin/mqttGateway2.pl'],
    }
  }

  service { 'mqttGateway2':
    ensure  => 'running',
    enable  => true,
    require => File['mqttGateway2.init'],
  }

}
