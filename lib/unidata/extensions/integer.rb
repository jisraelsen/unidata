module Unidata
  module Extensions
    module Integer
      def typecast(value)
        value.kind_of?(::Integer) ? value : value.to_i
      end

      def to_unidata(value)
        value
      end

      def from_unidata(value)
        typecast(value)
      end
    end
  end
end

class Integer
  extend Unidata::Extensions::Integer

  def to_d
    BigDecimal.new(self.to_s)
  end
end
