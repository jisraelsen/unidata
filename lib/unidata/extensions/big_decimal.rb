require 'bigdecimal'
require 'bigdecimal/util'

module Unidata
  module Extensions
    module BigDecimal
      def typecast(value)
        value.kind_of?(::BigDecimal) ? value : value.to_d
      end

      def to_unidata(value)
        (value * 100).to_i
      end

      def from_unidata(value)
        typecast(value) / 100
      end
    end
  end
end

class BigDecimal
  extend Unidata::Extensions::BigDecimal
end
