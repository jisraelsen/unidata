module Unidata
  module Extensions
    module Date
      PICK_EPOCH = ::Date.parse('1968-01-01')

      def to_unidata(value)
        (value - PICK_EPOCH).to_i
      end

      def from_unidata(value)
        PICK_EPOCH + value.to_i
      end
    end
  end
end

class Date
  extend Unidata::Extensions::Date
end
