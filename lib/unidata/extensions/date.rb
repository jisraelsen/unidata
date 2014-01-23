require 'date'

module Unidata
  module Extensions
    module Date
      PICK_DAY_ZERO = ::Date.parse('1967-12-31')

      def typecast(value)
        value.kind_of?(::Date) ? value : value.send(:to_date)
      end

      def to_unidata(value)
        if value == nil
          ''
        else
          (value - PICK_DAY_ZERO).to_i
        end
      end

      def from_unidata(value)
        if value == ''
          nil
        else
          PICK_DAY_ZERO + value.to_i
        end
      end
    end
  end
end

class Date
  extend Unidata::Extensions::Date
end
