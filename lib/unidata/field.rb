module Unidata
  class Field
    attr_reader :index, :name, :type, :formatter

    def initialize(index, name, type=String)
      @index = [*index]
      @name = name
      @type = type
    end

    def to_unidata(value)
      type.to_unidata(value)
    end

    def from_unidata(value)
      type.from_unidata(value)
    end
  end
end
