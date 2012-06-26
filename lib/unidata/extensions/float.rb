module Unidata
  module Extensions
    module Float
      def typecast(value)
        value.kind_of?(::Float) ? value : value.to_f
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

class Float
  extend Unidata::Extensions::Float
end
