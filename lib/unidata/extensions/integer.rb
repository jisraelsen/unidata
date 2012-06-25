module Unidata
  module Extensions
    module Integer
      def to_unidata(value)
        value
      end

      def from_unidata(value)
        value.to_i
      end
    end
  end
end

class Integer
  extend Unidata::Extensions::Integer
end
