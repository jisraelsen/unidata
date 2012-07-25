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

      def field(index, name, type=String, options={})
        fields[name.to_sym] = Field.new(index, name, type, options)
        define_attribute_accessor(name)
      end

      def to_unidata(instance)
        record = Unidata::UniDynArray.new

        fields.each do |key, field|
          next if key == :id

          value = instance.send(key)
          next if value.nil?
          record.replace *field.index, field.to_unidata(value)
        end

        record
      end

      def from_unidata(record)
        instance = new

        fields.each do |key, field|
          next if key == :id

          value = record.extract(*field.index).to_s
          instance.send("#{key}=", field.from_unidata(value))
        end

        instance
      end

      def exists?(id)
        connection.exists?(filename, id)
      end

      def find(id)
        if record = connection.read(filename, id)
          instance = from_unidata(record)
          instance.id = id
          instance
        end
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

    def initialize(attributes={})
      initialize_attributes

      attributes.each do |key, value|
        next unless self.class.field?(key.to_sym)
        write_attribute(key, value)
      end
    end

    def save
      record = self.class.to_unidata(self)
      self.class.connection.write(self.class.filename, id, record)
    end

    private
    def initialize_attributes
      @attributes = {}

      self.class.fields.each do |key, field|
        write_attribute(key, field.default)
      end
    end

    def read_attribute(attribute_name)
      @attributes[attribute_name.to_sym]
    end

    def write_attribute(attribute_name, value)
      field = self.class.fields[attribute_name.to_sym]
      value = field.typecast(value) unless value.nil?

      @attributes[attribute_name.to_sym] = value
    end
  end
end
