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
        define_attribute_finder(name)
      end

      def to_unidata(instance)
        record = Unidata::UniDynArray.new

        fields.each do |key, field|
          next if key == :id

          value = instance.send(key)
          next if value.nil?

          a_field, a_value, a_subvalue = field.index
          a_string = field.to_unidata(value)

          if a_subvalue
            record.replace a_field, a_value, a_subvalue, a_string
          elsif a_value
            record.replace a_field, a_value, a_string
          else
            record.replace a_field, a_string
          end
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

      def find_by(name, value)
        field_number = "F#{fields[name.to_sym].index.first}"
        connection.select(filename, "#{field_number} EQ \"#{value}\"").map do |id|
          find(id)
        end
      end

      def delete(id)
        connection.delete_record(filename, id)
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

      def define_attribute_finder(attribute_name)
        instance_eval <<-end_eval
          def find_by_#{attribute_name}(value)
            find_by(:#{attribute_name}, value)
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

    def destroy
      self.class.connection.delete_record(self.class.filename, id)
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
