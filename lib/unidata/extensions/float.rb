module Unidata
  module Extensions
    module Float
      def to_unidata(value)
        ::BigDecimal.to_unidata(value)
      end

      def from_unidata(value)
        ::BigDecimal.from_unidata(value).to_f
      end
    end
  end
end

class Float
  extend Unidata::Extensions::Float
end
