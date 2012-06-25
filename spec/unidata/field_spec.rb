require 'spec_helper'

describe Unidata::Field do
  subject { Unidata::Field }

  describe '#initialize' do
    it 'captures and assigns arguments' do
      field = subject.new(1, :date, Date)
      field.index.should == [1]
      field.name.should == :date
      field.type.should == Date
    end

    it 'accepts multivalued indexes' do
      field = subject.new([1,2], :name)
      field.index.should == [1,2]
    end

    it 'defaults type to String' do
      field = subject.new(2, :name)
      field.type.should == String
    end
  end

  describe '#to_unidata' do
    context 'when type is Time' do
      it 'converts value to pick time' do
        field = subject.new(1, :created_at, Time)
        field.to_unidata(Time.parse('2012-04-02 12:34:00')).should == 16163
      end
    end

    context 'when type is Date' do
      it 'converts value to pick time' do
        field = subject.new(1, :created_on, Date)
        field.to_unidata(Date.parse('2012-04-03')).should == 16164
      end
    end

    context 'when type is String' do
      it 'upcases value' do
        field = subject.new(1, :name, String)
        field.to_unidata('John Doe').should == 'JOHN DOE'
      end
    end

    context 'when type is Float' do
      it 'multiplies value by 100 and converts to an integer' do
        field = subject.new(1, :price, Float)
        field.to_unidata(123.32).should == 12332
      end
    end

    context 'when type is BigDecimal' do
      it 'multiplies value by 100 and converts to an integer' do
        field = subject.new(1, :price, BigDecimal)
        field.to_unidata(BigDecimal.new('123.32')).should == 12332
      end
    end

    context 'when type is Integer' do
      it 'does nothing' do
        field = subject.new(1, :age, Integer)
        field.to_unidata(45).should == 45
      end
    end
  end

  describe '#from_unidata' do
    context 'when type is Time' do
      it 'converts value from pick time' do
        field = subject.new(1, :created_at, Time)
        field.from_unidata(16163).should == Time.parse('2012-04-02 00:00:00')
      end
    end

    context 'when type is Date' do
      it 'converts value from pick time' do
        field = subject.new(1, :created_on, Date)
        field.from_unidata(16164).should == Date.parse('2012-04-03')
      end
    end

    context 'when type is String' do
      it 'does nothing' do
        field = subject.new(1, :name, String)
        field.from_unidata('JOHN DOE').should == 'JOHN DOE'
      end
    end

    context 'when type is Float' do
      it 'converts value to Float and divides by 100' do
        field = subject.new(1, :price, Float)
        field.from_unidata(12332).should == 123.32
      end
    end

    context 'when type is BigDecimal' do
      it 'converts value to BigDecimal and divides by 100' do
        field = subject.new(1, :price, BigDecimal)
        field.from_unidata(12332).should == BigDecimal.new('123.32')
      end
    end

    context 'when type is Integer' do
      it 'converts to an Integer' do
        field = subject.new(1, :age, Integer)
        field.from_unidata('45').should == 45
      end
    end
  end
end

