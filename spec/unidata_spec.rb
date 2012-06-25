require 'spec_helper'

describe Unidata do
  before(:each) do
    @config = { :user => 'test', :password => 'secret', :host => 'localhost', :data_dir => 'testdir' }
  end

  describe '.prepare_connection' do
    it 'prepares a unidata connection with config options' do
      Unidata.prepare_connection @config

      Unidata.connection.should be_kind_of(Unidata::Connection)
      Unidata.connection.user.should == @config[:user]
      Unidata.connection.password.should == @config[:password]
      Unidata.connection.host.should == @config[:host]
      Unidata.connection.data_dir.should == @config[:data_dir]
    end

    it 'should not open the connection' do
      Unidata.prepare_connection @config
      Unidata.connection.should_not be_open
    end
  end
end
