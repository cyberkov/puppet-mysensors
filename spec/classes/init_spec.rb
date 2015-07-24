require 'spec_helper'
describe 'mysensors' do

  context 'with defaults for all parameters' do
    it { should contain_class('mysensors') }
  end
end
