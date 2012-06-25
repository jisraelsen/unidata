require 'bigdecimal'

module Unidata
  module Extensions
    module BigDecimal
      def to_unidata(value)
        (value * 100).to_i
      end

      def from_unidata(value)
        ::BigDecimal.new(value.to_s) / 100
      end
    end
  end
end

class BigDecimal
  extend Unidata::Extensions::BigDecimal
end
