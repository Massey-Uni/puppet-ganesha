require 'spec_helper'
describe 'ganesha' do

  context 'with defaults for all parameters' do
    it { should contain_class('ganesha') }
  end
end
