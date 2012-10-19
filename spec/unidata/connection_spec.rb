require 'spec_helper'

describe Unidata::Connection do
  let(:connection) { Unidata::Connection.new('test', 'secret', 'localhost', 'tmp') }

  before(:each) do
    @session = double('UniSession', :set_data_source_type => nil, :connect => nil)

    Unidata.unijava.stub(:open_session).and_return(@session)
    Unidata.unijava.stub(:close_session)
  end

  describe '#initialize' do
    it 'captures and assigns arguments' do
      connection.user.should == 'test'
      connection.password.should == 'secret'
      connection.host.should == 'localhost'
      connection.data_dir.should == 'tmp'
    end
  end

  describe '#open?' do
    context 'with existing active session' do
      it 'returns true' do
        @session.stub(:is_active).and_return(true)

        connection.open
        connection.open?.should == true
      end
    end

    context 'with existing inactive session' do
      it 'returns false' do
        @session.stub(:is_active).and_return(false)

        connection.open
        connection.open?.should == false
      end
    end

    context 'without existing session' do
      it 'returns false' do
        connection.open?.should == false
      end
    end
  end

  describe '#open' do
    it 'opens a new session' do
      Unidata.unijava.should_receive(:open_session)
      connection.open
    end

    it 'sets data source type to UNIDATA' do
      @session.should_receive(:set_data_source_type).with('UNIDATA')
      connection.open
    end

    it 'connects the session' do
      @session.should_receive(:connect).with(connection.host, connection.user, connection.password, connection.data_dir)
      connection.open
    end
  end

  describe '#close' do
    it 'closes the session' do
      connection.open

      Unidata.unijava.should_receive(:close_session).with(@session)
      connection.close
    end
  end

  describe '#select' do
    before(:each) do
      @session.stub(:command).and_return(double.as_null_object)
      @session.stub(:select_list)
    end

    it 'executes the correct command' do
      connection.open

      @session.should_receive(:command).with('SELECT NAMES-FILE TO 0 WITH NAME EQ "JAMES,BILL"')
      connection.select('NAMES-FILE', 'NAME EQ "JAMES,BILL"')
    end

    it 'fetchs the correct select list' do
      connection.open
      select_list = double

      @session.should_receive(:select_list).with(5).and_return(select_list)
      connection.select('NAMES-FILE', 'NAME EQ "JAMES,BILL"', 5)
    end

    it 'returns a SelectList' do
      connection.open
      connection.select('NAMES-FILE', 'NAME EQ "JAMES,BILL"').should be_a(Unidata::SelectList)
    end
  end

  describe '#exists?' do
    before(:each) do
      @file = double('UniFile', :close => nil, :read_field => nil)
      @session.stub(:open).and_return(@file)

      connection.open
    end

    it 'opens file with filename' do
      @session.should_receive(:open).with('TEST')
      connection.exists?('TEST', 123)
    end

    it 'reads record_id field from file' do
      @file.should_receive(:read_field).with(123, 0)
      connection.exists?('TEST', 123)
    end

    it 'closes file' do
      @file.should_receive(:close)
      connection.exists?('TEST', 123)
    end

    context 'when file has given record_id' do
      it 'returns true' do
        @file.stub(:read_field).and_return('123')
        connection.exists?('TEST', 123).should == true
      end
    end

    context 'when file has no given record_id' do
      it 'returns false' do
        uni_file_exception = package_local_constructor Unidata::UniFileException

        @file.stub(:read_field).and_raise(uni_file_exception)
        connection.exists?('TEST', 123).should == false
      end
    end
  end

  describe '#read' do
    before(:each) do
      @file = double('UniFile', :close => nil, :read => nil)
      @session.stub(:open).and_return(@file)

      connection.open
    end

    it 'opens file in session' do
      @session.should_receive(:open).with('TEST')
      connection.read('TEST', 123)
    end

    it 'reads record from file' do
      @file.should_receive(:read).with(123)
      connection.read('TEST', 123)
    end

    it 'closes file' do
      @file.should_receive(:close)
      connection.read('TEST', 123)
    end

    context 'when record exists' do
      it 'returns record as a Unidata::UniDynArray' do
        @file.stub(:read).and_return('')
        connection.read('TEST', 123).should be_kind_of(Unidata::UniDynArray)
      end
    end

    context 'when record does not exist' do
      it 'returns nil' do
        uni_file_exception = package_local_constructor Unidata::UniFileException

        @file.stub(:read).and_raise(uni_file_exception)
        connection.read('TEST', 123).should be_nil
      end
    end
  end

  describe '#read_field' do
    before(:each) do
      @file = double('UniFile', :close => nil, :read_field => nil)
      @session.stub(:open).and_return(@file)

      connection.open
    end

    it 'opens file with filename' do
      @session.should_receive(:open).with('TEST')
      connection.read_field('TEST', 123, 5)
    end

    it 'reads field from file' do
      @file.should_receive(:read_field).with(123, 5)
      connection.read_field('TEST', 123, 5)
    end

    it 'closes file' do
      @file.should_receive(:close)
      connection.read_field('TEST', 123, 5)
    end

    context 'when field exists' do
      it 'returns value as a String' do
        @file.stub(:read_field).and_return(43245)
        connection.read_field('TEST', 123, 5).should == '43245'
      end
    end

    context 'when field does not exist' do
      it 'returns nil' do
        uni_file_exception = package_local_constructor Unidata::UniFileException

        @file.stub(:read_field).and_raise(uni_file_exception)
        connection.read_field('TEST', 123, 5).should be_nil
      end
    end
  end

  describe '#write' do
    before(:each) do
      @file = double('UniFile', :close => nil, :write => nil)
      @session.stub(:open).and_return(@file)
      @record = Unidata::UniDynArray.new

      connection.open
    end

    it 'opens file in session' do
      @session.should_receive(:open).with('TEST')
      connection.write('TEST', 123, @record)
    end

    it 'calls to_unidata on record if record not a Unidata::UniDynArray' do
      record = double('Record')
      record.should_receive(:to_unidata).and_return(Unidata::UniDynArray.new)

      connection.write('TEST', 123, record)
    end

    it 'writes record to file' do
      @file.should_receive(:write).with(123, @record)
      connection.write('TEST', 123, @record)
    end

    it 'closes file' do
      @file.should_receive(:close)
      connection.write('TEST', 123, @record)
    end
  end

  describe '#write_field' do
    before(:each) do
      @file = double('UniFile', :close => nil, :write_field => nil)
      @session.stub(:open).and_return(@file)

      connection.open
    end

    it 'opens file with filename' do
      @session.should_receive(:open).with('TEST')
      connection.write_field('TEST', 123, 'value', 5)
    end

    it 'writes field to file' do
      @file.should_receive(:write_field).with(123, 'value', 5)
      connection.write_field('TEST', 123, 'value', 5)
    end

    it 'closes file' do
      @file.should_receive(:close)
      connection.write_field('TEST', 123, 'value', 5)
    end
  end
end
