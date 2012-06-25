module Unidata
  module Extensions
    module Time
      def to_unidata(value)
        ::Date.to_unidata(value.to_date)
      end

      def from_unidata(value)
        ::Date.from_unidata(value).to_time
      end
    end
  end
end

class Time
  extend Unidata::Extensions::Time
end
