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

  describe '#typecast' do
    context 'when type is Date' do
      context 'when value is a Date' do
        it 'returns value' do
          value = Date.today

          field = subject.new(1, :created_on, Date)
          field.typecast(value).should == value
        end
      end

      context 'when value is not a Date' do
        it 'converts value to a Date' do
          value = Time.parse('2012-01-01 12:00:00')

          field = subject.new(1, :created_on, Date)
          field.typecast(value).should == Date.parse('2012-01-01')
        end
      end
    end

    context 'when type is String' do
      context 'when value is a String' do
        it 'returns value' do
          value = 'John Doe'

          field = subject.new(1, :name, String)
          field.typecast(value).should == value
        end
      end

      context 'when value is not a String' do
        it 'converts value to a String' do
          value1 = Time.parse('2012-01-01 12:00:00')
          value2 = 12345

          field = subject.new(1, :name, String)
          field.typecast(value1).should == value1.to_s
          field.typecast(value2).should == '12345'
        end
      end
    end

    context 'when type is Float' do
      context 'when value is a Float' do
        it 'returns value' do
          value = 123.45

          field = subject.new(1, :price, Float)
          field.typecast(value).should == value
        end
      end

      context 'when value is not a Float' do
        it 'converts value to a Float' do
          value1 = BigDecimal.new('123.45')
          value2 = 12345

          field = subject.new(1, :price, Float)
          field.typecast(value1).should == 123.45
          field.typecast(value2).should == 12345.0
        end
      end
    end

    context 'when type is BigDecimal' do
      context 'when value is a BigDecimal' do
        it 'returns value' do
          value = BigDecimal.new('123.45')

          field = subject.new(1, :price, BigDecimal)
          field.typecast(value).should == value
        end
      end

      context 'when value is not a BigDecimal' do
        it 'converts value to a BigDecimal' do
          value1 = 123.45
          value2 = 12345

          field = subject.new(1, :price, BigDecimal)
          field.typecast(value1).should == BigDecimal.new('123.45')
          field.typecast(value2).should == BigDecimal.new('12345.0')
        end
      end
    end

    context 'when type is Integer' do
      context 'when value is a Integer' do
        it 'returns value' do
          value = 123

          field = subject.new(1, :price, Integer)
          field.typecast(value).should == value
        end
      end

      context 'when value is not a Integer' do
        it 'converts value to a Integer' do
          value1 = BigDecimal.new('123.45')
          value2 = 12345.0

          field = subject.new(1, :price, Integer)
          field.typecast(value1).should == 123
          field.typecast(value2).should == 12345
        end
      end
    end
  end

  describe '#to_unidata' do
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

