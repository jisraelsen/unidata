module Unidata
  class Model
    class << self
      attr_accessor :filename

      def connection
        Unidata.connection
      end

      def fields
        unless @fields
          @fields = {}
          field(0, :id)
        end

        @fields
      end

      def field?(name)
        fields.keys.include?(name.to_sym)
      end

      def field(index, name, type=String)
        fields[name.to_sym] = Field.new(index, name, type)
        define_attribute_accessor(name)
      end

      def to_unidata(instance)
        record = Unidata::UniDynArray.new

        instance.attributes.each do |key, value|
          next if key == :id

          field = fields[key]
          record.replace *field.index, field.to_unidata(value)
        end

        record
      end

      def from_unidata(record)
        instance = new

        fields.each do |key, field|
          next if key == :id

          instance.send(
            "#{key}=",
            field.from_unidata(record.extract(*field.index).to_s)
          )
        end

        instance
      end

      def exists?(id)
        connection.exists?(filename, id)
      end

      def find(id)
        record = connection.read(filename, id)

        instance = from_unidata(record)
        instance.id = id
        instance
      end

      private
      def define_attribute_accessor(attribute_name)
        class_eval <<-end_eval
          def #{attribute_name}
            read_attribute(:#{attribute_name})
          end

          def #{attribute_name}=(value)
            write_attribute(:#{attribute_name}, value)
          end
        end_eval
      end
    end

    attr_reader :attributes

    def initialize(attributes={})
      @attributes = {}
      attributes.each do |key,value|
        next unless self.class.field?(key.to_sym)
        @attributes[key.to_sym] = value
      end
    end

    def save
      record = self.class.to_unidata(self)
      self.class.connection.write(self.class.filename, id, record)
    end

    private
    def read_attribute(attribute_name)
      @attributes[attribute_name.to_sym]
    end

    def write_attribute(attribute_name, value)
      @attributes[attribute_name.to_sym] = value
    end
  end
end
