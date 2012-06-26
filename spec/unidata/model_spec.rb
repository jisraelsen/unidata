require 'spec_helper'

describe Unidata::Model do
  subject { Unidata::Model }

  class Record < Unidata::Model
    self.filename = 'TEST'

    field 1,      :name
    field 2,      :age,         Integer
    field 3,      :birth_date,  Date
    field [4,1],  :employer
    field [4,2],  :job_title
    field [4,3],  :salary,      BigDecimal
  end

  describe '.connection' do
    it 'returns the Unidata connection' do
      Unidata.stub('connection').and_return(double('connection'))
      subject.connection.should == Unidata.connection
    end
  end

  describe '.field' do
    it 'adds Field with given index, name, and type to fields hash' do
      field = Record.fields[:age]
      field.index.should == [2]
      field.name.should == :age
      field.type.should == Integer
    end

    it 'defines attribute reader/writer for field' do
      obj = Record.new
      obj.age = 25
      obj.age.should == 25
    end
  end

  describe '.to_unidata' do
    before(:each) do
      @obj = Record.new(
        :id         => '1234',
        :name       => 'John Doe',
        :age        => 25,
        :birth_date => Date.today,
        :employer   => 'Awesome Company',
        :job_title  => 'Manager',
        :salary     => BigDecimal.new('60_000.00')
      )
    end

    it 'converts model to UniDynArray' do
      record = Record.to_unidata(@obj)
      record.extract(1).to_s.should == 'JOHN DOE'
      record.extract(2).to_s.should == '25'
      record.extract(3).to_s.should == Date.to_unidata(Date.today).to_s
      record.extract(4, 1).to_s.should == 'AWESOME COMPANY'
      record.extract(4, 2).to_s.should == 'MANAGER'
      record.extract(4, 3).to_s.should == '6000000'
    end

    it 'skips id field' do
      record = Record.to_unidata(@obj)
      record.extract(0).to_s.should == ''
    end
  end

  describe '.from_unidata' do
    before(:each) do
      @record = Unidata::UniDynArray.new
      @record.replace 0, '123'
      @record.replace 1, 'JOHN DOE'
      @record.replace 2, 25
      @record.replace 3, Date.to_unidata(Date.today)
      @record.replace 4, 1, 'AWESOME COMPANY'
      @record.replace 4, 2, 'MANAGER'
      @record.replace 4, 3, 6_000_000
    end

    it 'converts UniDynArray to model' do
      obj = Record.from_unidata(@record)
      obj.name.should == 'JOHN DOE'
      obj.age.should == 25
      obj.birth_date.should == Date.today
      obj.employer.should == 'AWESOME COMPANY'
      obj.job_title.should == 'MANAGER'
      obj.salary.should == BigDecimal.new('60_000.00')
    end

    it 'skips id field' do
      obj = Record.from_unidata(@record)
      obj.id.should be_nil
    end
  end

  describe '.exists?' do
    before(:each) do
      @connection = double('connection')
      @connection.stub(:exists?).with('TEST', '123').and_return(true)
      @connection.stub(:exists?).with('TEST', '234').and_return(false)

      Unidata.stub(:connection).and_return(@connection)
    end

    it 'returns true if record with id exists in file' do
      Record.exists?('123').should == true
    end

    it 'returns false if record with id does not exist in file' do
      Record.exists?('234').should == false
    end
  end

  describe '.find' do
    before(:each) do
      @record = Unidata::UniDynArray.new
      @record.replace 1, 'JOHN DOE'
      @record.replace 2, 25
      @record.replace 3, Date.to_unidata(Date.today)
      @record.replace 4, 1, 'AWESOME COMPANY'
      @record.replace 4, 2, 'MANAGER'
      @record.replace 4, 3, 6_000_000

      @connection = double('connection', :read => @record)
      Unidata.stub(:connection).and_return(@connection)
    end

    it 'reads record from file' do
      @connection.should_receive(:read).with('TEST', '123').and_return(@record)
      Record.find('123')
    end

    it 'returns model' do
      obj = Record.find(123)
      obj.id.should == '123'
      obj.name.should == 'JOHN DOE'
      obj.age.should == 25
      obj.birth_date.should == Date.today
      obj.employer.should == 'AWESOME COMPANY'
      obj.job_title.should == 'MANAGER'
      obj.salary.should == BigDecimal.new('60_000.00')
    end
  end

  describe '#initialize' do
    it 'captures provied attributes' do
      instance = Record.new(:id => '123', :name => 'John Doe')
      instance.id.should == '123'
      instance.name.should == 'John Doe'
    end

    it 'ignores attributes that are not defined in fields' do
      instance = Record.new(:id => '123', :name => 'John Doe', :nickname => 'J-Dog')
      instance.should_not respond_to(:nickname)
    end

    it 'typecasts attributes' do
      instance = Record.new(
        :age => '12',
        :birth_date => Time.parse('2012-01-01 12:00:00'),
        :salary => '5000.00'
      )
      instance.age.should == 12
      instance.birth_date.should == Date.parse('2012-01-01')
      instance.salary.should == BigDecimal.new('5000.00')
    end
  end

  describe '#save' do
    it 'writes record to file' do
      connection = double('connection', :write => nil)
      Unidata.stub(:connection).and_return(connection)

      obj = Record.new(
        :id         => '1234',
        :name       => 'John Doe',
        :age        => 25,
        :birth_date => Date.today,
        :employer   => 'Awesome Company',
        :job_title  => 'Manager',
        :salary     => BigDecimal.new('60_000.00')
      )

      record = Unidata::UniDynArray.new
      record.replace 1, 'JOHN DOE'
      record.replace 2, 25
      record.replace 3, Date.to_unidata(Date.today)
      record.replace 4, 1, 'AWESOME COMPANY'
      record.replace 4, 2, 'MANAGER'
      record.replace 4, 3, 6_000_000

      connection.should_receive(:write).with('TEST', '1234', record)
      obj.save
    end
  end
end

