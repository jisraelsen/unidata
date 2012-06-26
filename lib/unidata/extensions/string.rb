module Unidata
  module Extensions
    module String
      def typecast(value)
        value.kind_of?(::String) ? value : value.to_s
      end

      def to_unidata(value)
        value.upcase
      end

      def from_unidata(value)
        typecast(value)
      end
    end
  end
end

class String
  extend Unidata::Extensions::String
end
