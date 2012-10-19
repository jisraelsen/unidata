module Unidata
  class Connection
    attr_reader :user, :password, :host, :data_dir

    def initialize(user, password, host, data_dir)
      @user = user
      @password = password
      @host = host
      @data_dir = data_dir
    end

    def open?
      !@session.nil? && @session.is_active
    end

    def open
      @session = Unidata.unijava.open_session
      @session.set_data_source_type "UNIDATA"
      @session.connect(host, user, password, data_dir)
    end

    def close
      Unidata.unijava.close_session @session
      @session = nil
    end

    def select(filename, condition="", list_number=0)
      command = "SELECT #{filename} TO #{list_number}"
      command << " WITH #{condition}" unless condition.empty?
      @session.command(command).exec
      @session.select_list list_number
    end

    def exists?(filename, record_id)
      exists = false

      open_file(filename) do |file|
        begin
          file.read_field(record_id, 0)
          exists = true
        rescue Unidata::UniFileException
        end
      end

      exists
    end

    def read(filename, record_id)
      record = nil

      open_file(filename) do |file|
        begin
          record = Unidata::UniDynArray.new(file.read(record_id))
        rescue Unidata::UniFileException
        end
      end

      record
    end

    def read_field(filename, record_id, field)
      value = nil

      open_file(filename) do |file|
        begin
          value = file.read_field(record_id, field).to_s
        rescue Unidata::UniFileException
        end
      end

      value
    end

    def write(filename, record_id, record)
      record = record.to_unidata unless record.kind_of?(Unidata::UniDynArray)

      open_file(filename) do |file|
        file.write(record_id, record)
      end
    end

    def write_field(filename, record_id, value, field)
      open_file(filename) do |file|
        file.write_field(record_id, value, field)
      end
    end

    def with_record_lock(filename, record_id, lock_flag=1)
      open_file(filename) do |file|
        retry_count = 0
        begin
          file.lock_record(record_id, lock_flag)
          yield
        rescue Unidata::UniFileException
          # try to obtain a record lock at most 3 times, then give up
          if retry_count < 2
            sleep 5

            retry_count += 1
            retry
          else
            raise
          end
        ensure
          file.unlock_record(record_id)
        end
      end
    end

    private
    def open_file(filename)
      begin
        file = @session.open filename
        yield file
      ensure
        file.close
      end
    end
  end
end
