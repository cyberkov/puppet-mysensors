require 'spec_helper'
describe 'mysensors::mqttgw' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  #include_context :hiera


  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {
      :osfamily => 'Debian'
    }
  end
  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  it do
    is_expected.to contain_file('/usr/local/sbin/mqttGateway2.pl').
             with({"owner"=>"root",
                   "group"=>"root",
                   "mode"=>"0755",
                   "source"=>"puppet:///modules/mysensors/mqttGateway2.pl"})
  end
  it do
    is_expected.to contain_file('/etc/mysensors').
             with({"ensure"=>"directory",
                   "mode"=>"0755",
                   "owner"=>"root",
                   "group"=>"root"})
  end
  context 'with Debian 8 and systemd' do
    let(:facts) do
      { 
        :osfamily => 'Debian',
        :systemd  => true
      } 
    end
    it do
      is_expected.to contain_file('mqttGateway2.init').
        with({"ensure"=>"present",
              "path"=>"/etc/systemd/system/mqttGateway2.service",
              "require"=>"File[/usr/local/sbin/mqttGateway2.pl]"})
    end
    it do
      is_expected.to contain_service('mqttGateway2').
        with({"ensure"=>"running",
              "enable"=>"true",
              "require"=>"File[mqttGateway2.init]"})
    end
  end

  context 'with Debian 8 and sysvinit' do
    let(:facts) do
      { 
        :osfamily => 'Debian',
        :systemd  => false
      } 
    end
    it do
      should contain_file('mqttGateway2.init').
        with({
          'ensure'  => 'present',
          'path'    => '/etc/init.d/mqttGateway2',
          'mode'    => '0755',
          "require" =>"File[/usr/local/sbin/mqttGateway2.pl]"
      })
    end

    it do
      should contain_service('mqttGateway2').
        with({"ensure"=>"running",
              "enable"=>"true",
              "require"=>"File[mqttGateway2.init]"})
    end
  end
end
