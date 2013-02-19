require 'spec_helper'

DEFAULT_PARAMS = { 'user' => 'ubuntu' }

describe 'lwr' do
  let(:params) { DEFAULT_PARAMS }  

  describe 'without ssl cert' do

    it { should_not contain_package('libssl-dev') } 

  end

  describe 'with ssl cert' do
    let(:params) { DEFAULT_PARAMS.merge({'ssl_pem' => '/path/to/pem'}) }
    
    it { should contain_package('libssl-dev') }
    
  end

  describe 'setting up server.init' do
    it { should contain_file('/usr/share/lwr/server.ini') }
  end 

  describe 'skipping private token' do
    it { should_not contain_file('/usr/share/lwr/server.ini').with_content(/private_key/) }
  end

  describe 'setting private token' do
    let(:params) { DEFAULT_PARAMS.merge({'private_token' => 'abcd'}) }

    it { should contain_file('/usr/share/lwr/server.ini').with_content(/private_key = abcd/) }
  end
end
