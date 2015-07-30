require 'spec_helper'

describe 'mysensors' do
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
      :osfamily => 'Debian',
      :architecture => 'armv7l'
    }
  end
  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      #:install_mqttgw => true,
    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  
  context 'with defaults for all parameters' do
    it { should contain_class('mysensors') }
  end

  it do
    is_expected.to contain_vcsrepo('/opt/mysensors_rpi').
             with({"ensure"=>"latest",
                   "provider"=>"git",
                   "source"=>"https://github.com/mysensors/Raspberry.git",
                   "notify"=>"Exec[librf24-bcm-make-all]"})
  end
  it do
    is_expected.to contain_exec('librf24-bcm-make-all').
             with({"command"=>"make all",
                   "cwd"=>"/opt/mysensors_rpi/librf24-bcm",
                   "refreshonly"=>"true",
                   "notify"=>"Exec[librf24-bcm-make-install]"})
  end
  it do
    is_expected.to contain_exec('librf24-bcm-make-install').
             with({"command"=>"make install",
                   "cwd"=>"/opt/mysensors_rpi/librf24-bcm",
                   "refreshonly"=>"true",
                   "notify"=>"Exec[mysensors-make-all]"})
  end
  it do
    is_expected.to contain_exec('mysensors-make-all').
             with({"command"=>"make all",
                   "cwd"=>"/opt/mysensors_rpi",
                   "notify"=>"Exec[mysensors-make-install]",
                   "creates"=>"/opt/mysensors_rpi/PiGatewaySerial"})
  end
  it do
    is_expected.to contain_exec('mysensors-make-install').
             with({"command"=>"make install",
                   "cwd"=>"/opt/mysensors_rpi",
                   "creates"=>"/etc/init.d/PiGatewaySerial"})
  end
  it do
    is_expected.to contain_service('PiGatewaySerial').
             with({"ensure"=>"running",
                   "enable"=>"true",
                   "require"=>"Exec[mysensors-make-install]"})
  end

  context "with install_mqttgw set to true" do
    let(:params) do
      {
        :install_mqttgw => true,
      }
    end
    it { should contain_class('mysensors::mqttgw') }
  end
end
