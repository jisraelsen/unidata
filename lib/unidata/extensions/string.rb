module Unidata
  module Extensions
    module String
      def to_unidata(value)
        value.upcase
      end

      def from_unidata(value)
        value
      end
    end
  end
end

class String
  extend Unidata::Extensions::String
end
