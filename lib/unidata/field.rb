module Unidata
  class Field
    attr_reader :index, :name, :type

    def initialize(index, name, type=String, options={})
      @index = [*index]
      @name = name
      @type = type
      @default = options[:default]
    end

    def default
      if @default.respond_to?(:call)
        @default.call
      else
        @default
      end
    end

    def typecast(value)
      type.typecast(value)
    end

    def to_unidata(value)
      type.to_unidata(value)
    end

    def from_unidata(value)
      type.from_unidata(value)
    end
  end
end
